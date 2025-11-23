using { /Fortnite.com/Devices }
using { /Fortnite.com/Vehicles }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

car_spawn_device := class(creative_device):
    @editable
    Buttons : []button_device = array{}

    @editable
    CarSpawner : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}

    var CurrentVehicle : ?fort_vehicle = false
    var CurrentAgent : ?agent = false
    var DespawnTimerActive : logic = false
    var SomeoneInCar : logic = false  # NEW: Track if anyone is in the car

    OnBegin<override>()<suspends>:void =
        # Disable the spawner initially so the car isn't in the world
        CarSpawner.Disable()
        # Subscribe to all buttons in the array
        for (Button : Buttons):
            Button.InteractedWithEvent.Subscribe(OnButtonPressed)
        CarSpawner.SpawnedEvent.Subscribe(OnVehicleSpawned)
        CarSpawner.AgentExitsVehicleEvent.Subscribe(OnAgentExits)
        CarSpawner.AgentEntersVehicleEvent.Subscribe(OnAgentEnters)

    OnButtonPressed(Agent : agent):void =
        if (CurrentVehicle = false):
            set CurrentAgent = option{Agent}
            # Enable the spawner and spawn the car when the button is pressed
            CarSpawner.Enable()
            CarSpawner.RespawnVehicle()

    OnVehicleSpawned(Vehicle:fort_vehicle):void =
        if (Agent := CurrentAgent?):
            # Assign the saved agent as the driver of the newly spawned vehicle
            CarSpawner.AssignDriver(Agent)
            set CurrentVehicle = option{Vehicle}
            set SomeoneInCar = true  # Someone is now in the car

    OnAgentExits(Agent:agent):void =
        # FIXED: Start despawn timer when ANYONE exits, not just the original spawner
        if (DespawnTimerActive = false):
            set DespawnTimerActive = true
            set SomeoneInCar = false
            spawn{DespawnVehicleAfterDelay()}

    OnAgentEnters(Agent:agent):void =
        # Cancel the despawn timer if anyone re-enters the vehicle
        set DespawnTimerActive = false
        set SomeoneInCar = true

    DespawnVehicleAfterDelay()<suspends>:void =
        Sleep(10.0)
        # FIXED: Only despawn if timer is still active AND no one got back in
        if (DespawnTimerActive = true, SomeoneInCar = false):
            if (Vehicle := CurrentVehicle?):
                CarSpawner.DestroyVehicle()
                set CurrentVehicle = false
                set CurrentAgent = false
                # Disable the spawner again so the car isn't in the world
                CarSpawner.Disable()
            set DespawnTimerActive = false
