
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
using {cc}

<#

░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗  ░█████╗░░█████╗░███╗░░██╗██╗░░░██╗███████╗██╗░░░██╗░█████╗░██████╗░
██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║  ██╔══██╗██╔══██╗████╗░██║██║░░░██║██╔════╝╚██╗░██╔╝██╔══██╗██╔══██╗
██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║  ██║░░╚═╝██║░░██║██╔██╗██║╚██╗░██╔╝█████╗░░░╚████╔╝░██║░░██║██████╔╝
██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║  ██║░░██╗██║░░██║██║╚████║░╚████╔╝░██╔══╝░░░░╚██╔╝░░██║░░██║██╔══██╗
╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║  ╚█████╔╝╚█████╔╝██║░╚███║░░╚██╔╝░░███████╗░░░██║░░░╚█████╔╝██║░░██║
░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝  ░╚════╝░░╚════╝░╚═╝░░╚══╝░░░╚═╝░░░╚══════╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝

░█████╗░██╗░░░░░░█████╗░░██████╗░██████╗███████╗░██████╗░░░██╗░░░██╗███████╗██████╗░░██████╗███████╗
██╔══██╗██║░░░░░██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝░░░██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝
██║░░╚═╝██║░░░░░███████║╚█████╗░╚█████╗░█████╗░░╚█████╗░░░░╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░
██║░░██╗██║░░░░░██╔══██║░╚═══██╗░╚═══██╗██╔══╝░░░╚═══██╗░░░░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░
╚█████╔╝███████╗██║░░██║██████╔╝██████╔╝███████╗██████╔╝██╗░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗
░╚════╝░╚══════╝╚═╝░░╚═╝╚═════╝░╚═════╝░╚══════╝╚═════╝░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝

█▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▀ █▀▄   █▄▄ █▄█   ▀█▀ █▀ ▄▀█ █▀█
█▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ ██▄ █▄▀   █▄█ ░█░   ░█░ ▄█ █▀█ █▀▄

▄▀█ █░░ █░░   █▀█ █ █▀▀ █░█ ▀█▀ █▀   █▀█ █▀▀ █▀ █▀▀ █▀█ █░█ █▀▀ █▀▄
█▀█ █▄▄ █▄▄   █▀▄ █ █▄█ █▀█ ░█░ ▄█   █▀▄ ██▄ ▄█ ██▄ █▀▄ ▀▄▀ ██▄ █▄▀

█▀▄ █▀█   █▄░█ █▀█ ▀█▀   █▀ █▀▀ █░░ █░░
█▄▀ █▄█   █░▀█ █▄█ ░█░   ▄█ ██▄ █▄▄ █▄▄
#>



#Create a custom waypointable class that can be used to create items that can Link to `waypoints` such as: custom droppers and upgraders
custom_waypointable<public>:=class<concrete>(SuperClassInaugurable):
    

    @editable prop  <public>       :        creative_prop        =     creative_prop{}
    @editable Type  <public>       :        types                  =   types.corner

    var LocalOwner : ?purchaseable = false
    var Placed:logic=false


    Action(_Waypoint:waypoint, _Conveyor:custom_conveyor, StartDex:int)<suspends>:void=
        if:
            Location := _Waypoint.OffConveyorLocation?
            Rotation := _Waypoint.OffConveyorRotation?
            prop.TeleportTo[vector3{X:=Location.X, Y:=Location.Y, Z:=Location.Z-300.0}, rotation{}]
        then:
            prop.MoveTo(Location, Rotation, 2.0)
        return
    
    Initialize<override>(Owner:purchaseable):void=
        set LocalOwner = option{Owner}

    GetAssociatedValue<public>():vector2={vector2{X:=0.0, Y:=0.0}}

# SIMPLIFIED: custom_dropper now just holds config data, no spawning logic
custom_dropper<public>:=class<concrete>(custom_waypointable):
    @editable ExitHeight <public> : float = {200.0}
    @editable PropSpawn <public> : creative_prop_asset = {DefaultCreativePropAsset}
    @editable PropSpawnRate <public> : float = {1.0}
    @editable Type<override> : types = types.dropper
    @editable CubeValue <public> : float = 100.0
    @editable GrantID <public> : int = 0

    GetAssociatedValue<override>():vector2=
        vector2{X:=CubeValue, Y:=CubeValue}

    Action<override>(_Waypoint:waypoint, _Conveyor:custom_conveyor, StartDex:int)<suspends>:void=
        (super:)Action(_Waypoint, _Conveyor, StartDex)
        # Note: Spawning logic is now handled by purchaseable_dropper

        
custom_upgrader<public>:=class<concrete>(custom_waypointable):
    @editable Type<override>           :        types      =   types.upgrader
    @editable MuliplyValueRange : vector2 = vector2{X:=100.0, Y:=200.0}

    GetAssociatedValue<override>():vector2=
        MuliplyValueRange

    Action<override>(_Waypoint:waypoint, _Conveyor:custom_conveyor, StartDex:int)<suspends>:void=
        (super:)Action(_Waypoint, _Conveyor, StartDex)


custom_conveyor<public>:=class<concrete>(Inaugurable):

    var NewLink : event(custom_waypointable) = event(custom_waypointable){} 

    @editable ConveyorSpeed <public>           :     float               =       {100.0}
    @editable ConveyorWaypoints <public>       :     []waypoint          =       array{}


    FindLastWaypoint<public>()<decides><transacts>:waypoint=
        EndWaypoints := for:
            I -> Waypoint : ConveyorWaypoints
        do:
            Waypoint.Input = types.end
            Waypoint

        EndWaypoints[0]


    GetDistanceToLastWaypoint<public>(InputDistance:vector3)<transacts><decides>:float=
        LastWaypointLocation := FindLastWaypoint[].Location.GetTransform().Translation
        Distance(InputDistance, LastWaypointLocation)


    
    Initialize<override>(Base:base):void=
        for:
            I -> Waypoint : ConveyorWaypoints
        do:
            Waypoint.Initialize(Base)


    OnBegin<public>():void=
        for:
            I -> Waypoint : ConveyorWaypoints
        do:
            Waypoint.Play(Self, I)

        


        


waypoint<public>:=class<concrete><final>(Inaugurable):

    var NewLink : event() = event(){} 
    @editable OffConveyorLocation : ?vector3 = option{vector3{}}
    @editable OffConveyorRotation : ?rotation = option{rotation{}}
    @editable Location <public> : creative_prop = creative_prop{}
    @editable Input <public> : types = types.corner
    var LinkedItem<public>: ?custom_waypointable = false
    var Owner: ?custom_conveyor = false
    var StartDex : int = 0
    var MaybeOrigin : ?transform = option{transform{}}

    Initialize<override>(Base:base):void=
        Location.Hide()

    Play(_Owner:custom_conveyor, _StartDex:int):void=
        set Owner = option{_Owner}; set StartDex = _StartDex
        Location.Hide()
    
    Link<public>(Item:custom_waypointable):void = 
        GlobalSuperlog("Linking")
        if:
            _Owner := Owner?
            Item.Type = Input
            not Item.Placed?
        then:
            
            Item.prop.Show()
            set Item.Placed = true
            set LinkedItem = option{Item}
            NewLink.Signal()
            spawn{ManageLinkedItem()}
            GlobalSuperlog("Linked")
            if:
                not MaybeOrigin?
            then:
                set MaybeOrigin = option{Item.prop.GetTransform()}

    
    Unlink<public>(Item:custom_waypointable):void=
        set Item.Placed = false
        if:
            BItem := LinkedItem?
            Origin := MaybeOrigin?
            
            BItem.prop.Hide()
        then:
            GlobalSuperlog("Unlinked")
            NewLink.Signal()
            if(BItem.prop.TeleportTo[Origin]){GlobalSuperlog("Teleported {Origin.Translation}")}
            


    ManageLinkedItem()<suspends>:void=
        if:
            Item := LinkedItem?
            _Owner := Owner?
        then:
            # Note: For droppers, spawning is now handled by purchaseable_dropper
            # This just manages the visual prop placement
            Item.Action(Self, _Owner, StartDex)
