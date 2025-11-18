using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using {cc}

purchaseable_dropper<public>:=class<concrete>(purchaseable):

    var Ptype <override> :  PurchaseableType = PurchaseableType.Dropper

    @editable WaypointableConfig : custom_dropper = custom_dropper{Type := types.dropper}
    @editable var LocationalConfig      <public> :  custom_waypointable_config = custom_waypointable_config{}

    var iWaypoint : ?waypoint = false
    
    # FIXED: Track spawned props PER DROPPER INSTANCE
    var SpawnedProps : []creative_prop = array{}
    var IsSpawning : logic = false
    var SpawnCancellation : event() = event(){}

    #Initializes the item
    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method and waits for it to finish
        (super:)Initialize(Hostess, I)
        
        #Lists out all the properties of the item
        Detail("purchaseable_waypointable")

        WaypointableConfig.Initialize(Self)

    #Runs after the item is bought
    Host<override>()<suspends>:void=
        block:
            if:
                Owner := MaybeOwner?
                Conveyor := GetConveyorConfig[Owner, LocationalConfig.ConveyorID]
                Waypoint := Conveyor.ConveyorWaypoints[LocationalConfig.WaypointID]
            then:
                GlobalSuperlog("Waypoint found")
                Waypoint.Link(WaypointableConfig)
                set iWaypoint = option{Waypoint}
                
                # Start spawning with THIS dropper's state
                set IsSpawning = true
                spawn{SpawnLoop(Conveyor, LocationalConfig.WaypointID)}
            else:
                GlobalSuperlog("No waypoint found")
        return

    # FIXED: Spawn loop per dropper instance
    SpawnLoop(Conveyor:custom_conveyor, StartDex:int)<suspends>:void=
        loop:
            race:
                block:
                    Sleep(WaypointableConfig.PropSpawnRate)
                    spawn{SpawnProp(Conveyor, StartDex)}
                block:
                    SpawnCancellation.Await()
                    GlobalSuperlog("Dropper spawn loop cancelled for this dropper")
                    return

    # FIXED: Spawn prop using THIS dropper's tracking
    SpawnProp(Conveyor:custom_conveyor, StartDex:int)<suspends>:void=
        var CurrentCubeValue : float = WaypointableConfig.CubeValue
        
        MaybeSpawnedProp := SpawnProp(WaypointableConfig.PropSpawn, vector3{X:=0.0,Y:=0.0,Z:=0.0}, rotation{})
        if:
            SpawnedProp := MaybeSpawnedProp(0)?
        then:
            # Track this prop in THIS dropper instance
            set SpawnedProps += array{SpawnedProp}
            
            SpawnedProp.Hide()
            var ActiveDex: int = StartDex
            
            loop:
                # Check if THIS dropper should stop
                if(not IsSpawning?)
                {
                    SpawnedProp.Dispose()
                    return
                }

                if:
                    CNextWaypoint := Conveyor.ConveyorWaypoints[ActiveDex]
                    CNextWaypointLocation := CNextWaypoint.Location
                    CNextWaypointLocationValue := CNextWaypointLocation.GetTransform().Translation
                    TransformMain := transform{Translation:=SpawnedProp.GetTransform().Translation, Scale:=vector3{X:=0.25, Y:=0.25, Z:=0.25}}
                    NextLocation := transform{Translation:=CNextWaypointLocationValue, Scale:=vector3{X:=0.25, Y:=0.25, Z:=0.25}}
                    SpawnedProp.TeleportTo[TransformMain]
                then:
                    if(ActiveDex = 0)
                    {
                        if(SpawnedProp.TeleportTo[vector3{X:=CNextWaypointLocationValue.X,Y:=CNextWaypointLocationValue.Y,Z:=CNextWaypointLocationValue.Z+WaypointableConfig.ExitHeight}, rotation{}])
                        {
                            spawn{ShowAfter(SpawnedProp, (55.0/WaypointableConfig.ExitHeight)/10.0)}
                            SpawnedProp.MoveTo(NextLocation, 55.0/WaypointableConfig.ExitHeight)
                        }
                    } 
                    else if:
                        DistanceToNextWaypoint := Distance(SpawnedProp.GetTransform().Translation, Conveyor.ConveyorWaypoints[ActiveDex].Location.GetTransform().Translation)
                    then:
                        SpawnedProp.MoveTo(NextLocation, DistanceToNextWaypoint/Conveyor.ConveyorSpeed)
                    
                    if:
                        CNextWaypoint.Input = types.upgrader
                        LinkedItem := CNextWaypoint.LinkedItem?
                    then:
                        set CurrentCubeValue *= GetRandomFloat(LinkedItem.GetAssociatedValue().X,LinkedItem.GetAssociatedValue().Y)
                    
                    set ActiveDex += 1
                else if:
                    LastWaypoint := Conveyor.ConveyorWaypoints[ActiveDex-1]
                    LastWaypoint.Input = types.end
                then:
                    GlobalSuperlog("Reached the end of the conveyor with value {CurrentCubeValue}")
                    if:
                        Base := MaybeOwner?  # MaybeOwner is the base
                        Player := Base.Players[0]
                        Value := Ceil[CurrentCubeValue]
                    then:
                        GrantMoney(Base, Player, WaypointableConfig.GrantID, Value, BypassZone)
                    
                    Sleep(0.01)
                    SpawnedProp.Dispose()
                    return
                else:
                    GlobalSuperlog("Error: cube reached an invalid waypoint")
                    SpawnedProp.Dispose()
                    return

    ShowAfter(Prop:creative_prop, Delay:float)<suspends>:void=
        Sleep(Delay)
        Prop.Show()

    # FIXED: Stop THIS dropper and clean up ITS props
    StopSpawning():void=
        GlobalSuperlog("Stopping THIS dropper's spawning")
        SpawnCancellation.Signal()
        set IsSpawning = false
        CleanupAllProps()

    CleanupAllProps():void=
        GlobalSuperlog("Cleaning up {SpawnedProps.Length} props from THIS dropper")
        for(SpawnedProp : SpawnedProps)
        {
            if(SpawnedProp.IsValid[])
            {
                SpawnedProp.Dispose()
            }
        }
        set SpawnedProps = array{}

    OnRebirth<override>():void=
        (super:)OnRebirth()

        # Stop THIS dropper's spawning and clean up ITS props
        StopSpawning()

        if:
            Waypoint := iWaypoint?
        then:
            Waypoint.Unlink(WaypointableConfig)
            set iWaypoint = {false}
