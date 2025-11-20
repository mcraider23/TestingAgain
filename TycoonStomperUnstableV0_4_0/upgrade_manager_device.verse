# upgrade_manager_device.verse
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {Runtimeinstantiables}
using {HudSystem}
using {cc}
using {Stomper}
using {Purchaseables}

# Persistable class to store player upgrades
player_upgrades := class<final><persistable>:
    UnlimitedAmmo<public> : logic = false
    NoReload<public> : logic = false
    DoubleJump<public> : logic = false
    SpeedBoost<public> : float = 0.0

# Persistent manager device
upgrade_manager_device<public> := class(creative_device):
    var PlayerUpgrades : [player]player_upgrades = map{}

    # Get or create per-player upgrades (persistent)
    GetPlayerUpgrades(Player : player) : player_upgrades =
        if (ExistingUpgrades := PlayerUpgrades[Player]):
            ExistingUpgrades
        else:
            NewUpgrades := player_upgrades{}
            if (set PlayerUpgrades[Player] = NewUpgrades):
                NewUpgrades
            else:
                player_upgrades{}

    SetUnlimitedAmmo(Player : player, Enabled : logic) : void =
        Up := GetPlayerUpgrades(Player)
        New := player_upgrades{
            UnlimitedAmmo := Enabled,
            NoReload := Up.NoReload,
            DoubleJump := Up.DoubleJump,
            SpeedBoost := Up.SpeedBoost
        }
        if (set PlayerUpgrades[Player] = New) {}

    SetNoReload(Player : player, Enabled : logic) : void =
        Up := GetPlayerUpgrades(Player)
        New := player_upgrades{
            UnlimitedAmmo := Up.UnlimitedAmmo,
            NoReload := Enabled,
            DoubleJump := Up.DoubleJump,
            SpeedBoost := Up.SpeedBoost
        }
        if (set PlayerUpgrades[Player] = New) {}

    SetDoubleJump(Player : player, Enabled : logic) : void =
        Up := GetPlayerUpgrades(Player)
        New := player_upgrades{
            UnlimitedAmmo := Up.UnlimitedAmmo,
            NoReload := Up.NoReload,
            DoubleJump := Enabled,
            SpeedBoost := Up.SpeedBoost
        }
        if (set PlayerUpgrades[Player] = New) {}

    SetSpeedBoost(Player : player, BoostPercent : float) : void =
        Up := GetPlayerUpgrades(Player)
        New := player_upgrades{
            UnlimitedAmmo := Up.UnlimitedAmmo,
            NoReload := Up.NoReload,
            DoubleJump := Up.DoubleJump,
            SpeedBoost := BoostPercent
        }
        if (set PlayerUpgrades[Player] = New) {}

    HasUnlimitedAmmo(Player : player):logic=
        Up:=GetPlayerUpgrades(Player)
        Up.UnlimitedAmmo

    HasNoReload(Player : player):logic=
        Up:=GetPlayerUpgrades(Player)
        Up.NoReload

    HasDoubleJump(Player : player):logic=
        Up:=GetPlayerUpgrades(Player)
        Up.DoubleJump

    GetSpeedBoost(Player : player):float=
        Up:=GetPlayerUpgrades(Player)
        Up.SpeedBoost