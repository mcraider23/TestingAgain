using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Colors }

# Persistent state for material changer
prop_material_changer_state := class<final><persistable>:
    CurrentMaterialIndex : int = 0

prop_material_changer := class(creative_device):

    @editable
    Button : button_device = button_device{}

    @editable
    var Props : []creative_prop = array{}

    @editable
    var MaterialArray : []material = array{}

    # Persistent state
    var State : prop_material_changer_state = prop_material_changer_state{}

    OnBegin<override>()<suspends> : void =
        Button.InteractedWithEvent.Subscribe(OnButtonPressed)
        # Restore last used material on startup
        if (Material := MaterialArray[State.CurrentMaterialIndex]):
            for (Prop : Props):
                Prop.SetMaterial(Material)

    OnButtonPressed(Agent : agent) : void =
        # Cycle to next material index
        NewIndex := State.CurrentMaterialIndex + 1
        if (NewIndex >= MaterialArray.Length):
            set State = prop_material_changer_state{CurrentMaterialIndex := 0}
        else:
            set State = prop_material_changer_state{CurrentMaterialIndex := NewIndex}

        # Apply material to all props
        if (Material := MaterialArray[State.CurrentMaterialIndex]):
            for (Prop : Props):
                Prop.SetMaterial(Material)