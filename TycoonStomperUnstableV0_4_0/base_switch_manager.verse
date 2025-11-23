using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

base_switch_manager := class(creative_device):
    
    # Add all switches for this base here
    @editable
    Switches : []switch_device = array{}
    
    # Trigger this when a player claims the base or rebirths
    @editable
    ResetTrigger : trigger_device = trigger_device{}
    
    # Optional: Auto-reset delay (how long to wait after trigger)
    @editable
    ResetDelay : float = 1.0
    
    OnBegin<override>()<suspends>:void =
        ResetTrigger.TriggeredEvent.Subscribe(OnReset)
    
    OnReset(MaybeAgent:?agent):void =
        Print("Switch reset triggered")
        if:
            Agent := MaybeAgent?
            Player := player[Agent]
        then:
            spawn{ResetAllSwitches(Player)}
        else:
            Print("No player found for switch reset")
    
    ResetAllSwitches(Player:player)<suspends>:void=
        Sleep(ResetDelay)
        Print("Resetting {Switches.Length} switches for player")
        
        var ResetCount : int = 0
        for(Switch : Switches):
            # Turn off the switch to reset it
            Switch.TurnOff(Player)
            set ResetCount += 1
        
        Print("Reset {ResetCount} switches")


