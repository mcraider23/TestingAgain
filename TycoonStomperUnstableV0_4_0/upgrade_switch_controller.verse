using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {Runtimeinstantiables}
using {HudSystem}
using {cc}
using {Stomper}
using {Purchaseables}

upgrade_switch_controller := class(creative_device):
    @editable
    UpgradeManager : upgrade_manager_device = upgrade_manager_device{}

    # Arrays of switches for each base; assign in Details panel
    @editable
    Base1_AmmoSwitches : []switch_device = array{}
    @editable
    Base1_ReloadSwitches : []switch_device = array{}
    @editable
    Base1_JumpSwitches : []switch_device = array{}
    @editable
    Base1_SpeedSwitches : []switch_device = array{}

    @editable
    Base2_AmmoSwitches : []switch_device = array{}
    @editable
    Base2_ReloadSwitches : []switch_device = array{}
    @editable
    Base2_JumpSwitches : []switch_device = array{}
    @editable
    Base2_SpeedSwitches : []switch_device = array{}

    @editable
    Base3_AmmoSwitches : []switch_device = array{}
    @editable
    Base3_ReloadSwitches : []switch_device = array{}
    @editable
    Base3_JumpSwitches : []switch_device = array{}
    @editable
    Base3_SpeedSwitches : []switch_device = array{}

    @editable
    Base4_AmmoSwitches : []switch_device = array{}
    @editable
    Base4_ReloadSwitches : []switch_device = array{}
    @editable
    Base4_JumpSwitches : []switch_device = array{}
    @editable
    Base4_SpeedSwitches : []switch_device = array{}

    OnBegin<override>()<suspends>:void=
        # Subscribe for all arrays in all bases
        for (Switch : Base1_AmmoSwitches):
            Switch.TurnedOnEvent.Subscribe(OnUnlimitedAmmoSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnUnlimitedAmmoSwitchOff)
        for (Switch : Base1_ReloadSwitches):
            Switch.TurnedOnEvent.Subscribe(OnNoReloadSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnNoReloadSwitchOff)
        for (Switch : Base1_JumpSwitches):
            Switch.TurnedOnEvent.Subscribe(OnDoubleJumpSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnDoubleJumpSwitchOff)
        for (Switch : Base1_SpeedSwitches):
            Switch.TurnedOnEvent.Subscribe(OnSpeedBoostSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnSpeedBoostSwitchOff)

        for (Switch : Base2_AmmoSwitches):
            Switch.TurnedOnEvent.Subscribe(OnUnlimitedAmmoSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnUnlimitedAmmoSwitchOff)
        for (Switch : Base2_ReloadSwitches):
            Switch.TurnedOnEvent.Subscribe(OnNoReloadSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnNoReloadSwitchOff)
        for (Switch : Base2_JumpSwitches):
            Switch.TurnedOnEvent.Subscribe(OnDoubleJumpSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnDoubleJumpSwitchOff)
        for (Switch : Base2_SpeedSwitches):
            Switch.TurnedOnEvent.Subscribe(OnSpeedBoostSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnSpeedBoostSwitchOff)

        for (Switch : Base3_AmmoSwitches):
            Switch.TurnedOnEvent.Subscribe(OnUnlimitedAmmoSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnUnlimitedAmmoSwitchOff)
        for (Switch : Base3_ReloadSwitches):
            Switch.TurnedOnEvent.Subscribe(OnNoReloadSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnNoReloadSwitchOff)
        for (Switch : Base3_JumpSwitches):
            Switch.TurnedOnEvent.Subscribe(OnDoubleJumpSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnDoubleJumpSwitchOff)
        for (Switch : Base3_SpeedSwitches):
            Switch.TurnedOnEvent.Subscribe(OnSpeedBoostSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnSpeedBoostSwitchOff)

        for (Switch : Base4_AmmoSwitches):
            Switch.TurnedOnEvent.Subscribe(OnUnlimitedAmmoSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnUnlimitedAmmoSwitchOff)
        for (Switch : Base4_ReloadSwitches):
            Switch.TurnedOnEvent.Subscribe(OnNoReloadSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnNoReloadSwitchOff)
        for (Switch : Base4_JumpSwitches):
            Switch.TurnedOnEvent.Subscribe(OnDoubleJumpSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnDoubleJumpSwitchOff)
        for (Switch : Base4_SpeedSwitches):
            Switch.TurnedOnEvent.Subscribe(OnSpeedBoostSwitchOn)
            Switch.TurnedOffEvent.Subscribe(OnSpeedBoostSwitchOff)

    # Handlers: always signature (Agent:agent):void
    OnUnlimitedAmmoSwitchOn(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetUnlimitedAmmo(Player, true)

    OnUnlimitedAmmoSwitchOff(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetUnlimitedAmmo(Player, false)

    OnNoReloadSwitchOn(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetNoReload(Player, true)

    OnNoReloadSwitchOff(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetNoReload(Player, false)

    OnDoubleJumpSwitchOn(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetDoubleJump(Player, true)

    OnDoubleJumpSwitchOff(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetDoubleJump(Player, false)

    OnSpeedBoostSwitchOn(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetSpeedBoost(Player, 0.1) # 10% speed boost

    OnSpeedBoostSwitchOff(Agent:agent):void=
        if (Player := player[Agent]):
            UpgradeManager.SetSpeedBoost(Player, 0.0) # Remove speed boost