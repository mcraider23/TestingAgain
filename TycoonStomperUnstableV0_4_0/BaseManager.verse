using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {Purchaseables}
using {/Fortnite.com/Teams}
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Runtimeinstantiables}
using {HudSystem}
using {cc}
using {Stomper}
#Defines what a 'Team' is and how it functions.
base<public>:=class<concrete><unique>(SuperInaugurable, Rebirthable, Runtime, StringReturnables, creative_device):

    var UniqueID:string = ""

    var selfindex:int = -1

    var Status : ClaimStatus = ClaimStatus.Unclaimed

    #The list of players on the team.
    var Players: []player = array{}

    var RootPlayer : ?player = false

    var Owner:tycoon_stomper = tycoon_stomper{}

    var Rebirthed: event(player) = event(player){}

    var MoneyLeague : money_league = money_league{}

    var MoneyGranted : event(tuple(player, int, int)) = event(tuple(player, int, int)){}

    var NewItemBought : event(purchaseable) = event(purchaseable){}

    var CFR : ClaimFauilreReason = ClaimFauilreReason.TooManyPlayers


    @editable var LeaveButton : button_device = button_device{}

    #The volume device that is used to claim the base.
    @editable var Base_Setup : base_setup = base_setup{}
    

    #The basic props that the base has.
    @editable var BasicProps: []basic_prop_buyable = array{}

    #The collectables that the base has.
    @editable var Collectables: []unique_collectable = array{}

    #The conveyors that the base has.
    @editable var Conveyors: []purchaseable_conveyor = array{}

    #The currencies that the base uses.
    @editable var Currencies : []currency_config = array{}

    #Dance floors that the base has.
    @editable var DanceFloors: []dancefloor_buyable = array{}

    #The conveyors that the base has.
    @editable var Droppers: []purchaseable_dropper = array{}

    #The gifts that the base has.
    @editable var Gifts: []unique_giftable = array{}

    #The hitables that the base has.
    @editable var Hitables: []hitable_buyable = array{}

    #Money wheel that the base has.
    @editable var MoneyWheel: []unique_moneywheel = array{}

    #The NPC spawners that the base has.
    @editable var NPCSpawners: []npc_buyable = array{}

    #Pets that the base has.
    @editable var Pets: []pet = array{}

    #The shootables that the base has.
    @editable var Shootables: []shootable_buyable = array{}

    #
    @editable var Upgraders: []purchaseable_upgrader = array{}

    #Hud Config
    @editable var UIConfig : []currency_ui_config = array{}


    #Player to pet map
    var PlayerToPetMap : [player]tuple(pet, logic) = map{}


    #Base Claim
    var AttemptedBaseClaim : event() = event(){}

    petmaxreached : event(player) = event(player){}
    


    #If you add a new purchaseable include it in this list for it to be initialized by this base.
    GetPurchaseArray():[][]purchaseable=
        array
        {
            BasicProps, 
            NPCSpawners, 
            Droppers, 
            Conveyors, 
            Upgraders, 
            Hitables, 
            Shootables, 
            DanceFloors, 
            Pets
        }

        
    


    
    <# 
    The maximum number of players that can be on the team.
    This is useful for games that have a 'base' that players can claim and share resources with each other.
    This kit isn't optimised for >1 players(Hence this not being editable); however, it will techincally function and work with multiple players.
    The kit will work with multiple players, money distribution, and all the other features that are included in the kit will be handled by the base.
    Some features will elect to grant money to all players in the base on event; whilst others will grant money to the player that triggered the event.
    I do not recommend changing this unless you know what you're doing.
    #> SizeLimit : int = 1
    

    InitializeAgent(A:agent)<transacts>:void=
        if:
            Player := player[A]
            not PlayerProfileDataMap[Player]
            set PlayerProfileDataMap[Player] = player_profile_data{}
        then:
            Owner.Config.Superlog("Inited player profile data")
            for:
                X := 0..100
                PlayerData := GetStats[Player]
            do:
                Source := player_profile_data:
                    CoreSaves:=ChangeCoreSave(PlayerData.CoreSaves, X, core_save{})
                    MakePlayerProfileData<constructor>(PlayerData)
                if. set PlayerProfileDataMap[Player] = Source
                if. DelidCurrencies[Player, Base_Setup.PersistenceCore]
                


        #If persistence is disabled then reset the currencies.
        if:
            Player := player[A]
            not Base_Setup.PersistCurrencies?
            DelidCurrencies[Player, Base_Setup.PersistenceCore]

        if:
            Player := player[A]
        then:
            if(set PlayerToPetMap[Player] = (pet{}, false)){}
           
        


        
        

    
    OnBegin<override>(IX:int):void=
        Base_Setup.OnBegin(Self, -1)
        Initialize(Self, IX)

        
    OnBought(Agent:agent):void=
        InitializeAgent(Agent)
            Print("Attempting to claim base")
            Base_Setup.BillBoardConfig.Instantiate()
            
            # FIXED: Check status BEFORE attempting claim
            if(Status = ClaimStatus.Claimed):
                if:
                    Player := player[Agent]
                then:
                    Base_Setup.HudConfig.OnFailurePlayer(Player)
                    Print("Base is already claimed")
                return
            
            if:
                AttemptClaimBase[Agent]
                Player := player[Agent]
                TempStats := Owner.GetPlayerStats[Player]
                TempStats.ClaimBase[Self]
                PlayerStats := GetCoreStats[Player, Base_Setup.PersistenceCore]
                AssociatedUnlocks := PlayerStats.AssociatedUnlocks
            then:
                # VERIFICATION: Check team assignment worked
                spawn{VerifyTeamAssignment(Player)}
                
                if:
                    not RootPlayer?
                then:
                    set RootPlayer = option{Player}
                set Owner.UnclaimedBases = Owner.UnclaimedBases.RemoveAllElements(Self)
                Base_Setup.PurchaseableConfigs.Purchase_Zone.OnSuccess(Player, false)
                for(I ->IGifts: Gifts){IGifts.InitGiftable(Player)}
                Base_Setup.VFX.OnEvent(Player)
                Owner.Config.Superlog("Player has {PlayerStats.Rebirths} Rebirths")
                
                for(Collectable:Collectables){Collectable.Show(Self)}
                Base_Setup.HudConfig.Initialize(Self)
                Base_Setup.HudConfig.OnSuccessfullPlayer(Player)
                UI := currency_ui{Player:=Player,  Configs:=UIConfig, owner:=Self}
                UI.Create()
                spawn{AwaitUIDestroy(UI)}
                
                # FIXED: Spawn delayed loading to avoid suspends effect error
                if:
                    Base_Setup.PersistUnlocks?
                then:
                    spawn{DelayedLoadUnlocks(AssociatedUnlocks)}
                else if:
                    DelidUnlocks[Player, Base_Setup.PersistenceCore]
                
                if:
                    Players.Length < SizeLimit
                then:
                    GlobalSuperlog("Still in the size limit")
                else:
                    Base_Setup.PurchaseableConfigs.Purchase_Zone.Hide(true)
                    Base_Setup.BillBoardConfig.Hide()

                AttemptedBaseClaim.Signal()


                    
                
                

                    
            else if:
                Player := player[Agent]
            then:
                if:
                    not AttemptClaimBase[Player]
                then:
                    set CFR = ClaimFauilreReason.TooManyPlayers
                else if:
                    TempStats := Owner.GetPlayerStats[Player]
                    not TempStats.ClaimBase[Self]
                then:
                    set CFR = ClaimFauilreReason.AlreadyOwnsBase


                
                Base_Setup.HudConfig.OnFailurePlayer(Player)
                Print("Base is already claimed or size limit was reached (Status: [== {CFR.ToStr()} ==]")

    # NEW: Helper method to verify team assignment
    VerifyTeamAssignment(Player:player)<suspends>:void=
        Sleep(0.5)  # Give it a moment to complete
        TC := Owner.GetPlayspace().GetTeamCollection()
        Teams := TC.GetTeams()
        if:
            PlayerTeam := TC.GetTeam[Player]
            Base_Setup.TeamToAddTo < Teams.Length
            ExpectedTeam := Teams[Base_Setup.TeamToAddTo]
        then:
            if:
                PlayerTeam = ExpectedTeam
            then:
                Owner.Config.Superlog("✓ TEAM VERIFIED: Player successfully assigned to team index {Base_Setup.TeamToAddTo} for base {Base_Setup.Name}")
            else:
                Owner.Config.Superlog("✗ TEAM MISMATCH: Player on WRONG team for base {Base_Setup.Name}!")
                Owner.Config.Superlog("  Expected team index: {Base_Setup.TeamToAddTo}")
                # Try to fix it by adding to team again
                if(TC.AddToTeam[Player, ExpectedTeam]):
                    Owner.Config.Superlog("  ✓ Fixed: Reassigned player to correct team")
                else:
                    Owner.Config.Superlog("  ✗ Failed to reassign player!")
        else:
            Owner.Config.Superlog("✗ TEAM ERROR: Could not get player's team or expected team!")

    # NEW: Helper method to handle delayed loading with suspends
    DelayedLoadUnlocks(AssociatedUnlocks:[]tuple(PurchaseableType, int))<suspends>:void=
        Owner.Config.Superlog("=== PERSISTENCE LOADING START ===")
        Owner.Config.Superlog("Associated Unlocks Length: {AssociatedUnlocks.Length}")
        
        for:
            Unlock : AssociatedUnlocks
        do:
            Owner.Config.Superlog("  - Type: {Unlock(0).ToStr()}, Index: {Unlock(1)}")
        
        # FIXED: Add delay to ensure all systems are initialized before loading
        Sleep(0.5)
        
        Owner.Config.Superlog("Loading {AssociatedUnlocks.Length} unlocks")
        for:
            AUnoock:AssociatedUnlocks
        do:
            Owner.Config.Superlog("Loading unlock: Type={AUnoock(0).ToStr()}, Index={AUnoock(1)}")
            Load(Self, AUnoock(0), AUnoock(1))
            # Small delay between loads to prevent race conditions
            Sleep(0.05)
        
        Owner.Config.Superlog("=== PERSISTENCE LOADING COMPLETE ===")

    #Waits for a player to enter the base and attempts to claim it.
    AwaitBaseClaim(IX:int)<suspends>:void=
        Print("== {Base_Setup.Name} Successfully Initialized ==")
        loop:
            PreventInf();
            Agent := Base_Setup.PurchaseableConfigs.OnBoughtEvent.Await(); GlobalSuperlog("ON BOUGHT EVENT")
            OnBought(Agent)
            
            

            
            

    AwaitUIDestroy(UI:currency_ui)<suspends>:void=
        loop:
            Rebirthed.Await()
            UI.Destroy();
    #Attempts to claim the base.
    AttemptClaimBase(A:agent)<transacts><decides>:void=
        Owner.Config.Superlog("=== ATTEMPTING TO CLAIM BASE ===")
        Owner.Config.Superlog("Base: {Base_Setup.Name}")
        Owner.Config.Superlog("Current Status: {Status.ToStr()}")
        Owner.Config.Superlog("Current Players: {Players.Length}/{SizeLimit}")
        
        if:
            Players.Length < SizeLimit
            Player := player[A]
        then:
            AddToTeam(Player)
            set Status = ClaimStatus.Claimed  # FIXED: Set status immediately after adding
            Owner.Config.Superlog("✓ Base Successfully Claimed!")
            Owner.Config.Superlog("New Status: {Status.ToStr()}")
            

        else:
            set Status = ClaimStatus.Claimed
            Owner.Config.Superlog("✗ Claim FAILED: Base already claimed or at size limit")


    AwaitRebirth()<suspends>:void=
    {
        Base_Setup.RebirthConfig.HudConfig.Initialize(Self)
        loop:
            Interactor := Base_Setup.RebirthConfig.RebirthButton.InteractedWithEvent.Await()
            if:
                Player := player[Interactor]
                PlayerStats := GetCoreStats[Player, Base_Setup.PersistenceCore]
                Rebirths := PlayerStats.Rebirths
                RebirthCurrencyValue := PlayerStats.AssociatedCurrencies[Base_Setup.RebirthConfig.RebirthCostCurrencyID]
                RebirthCostAmount := GetRebirthCostAmount[Self, Rebirths]
                RebirthCurrencyValue >= RebirthCostAmount
            then:
                Rebirthed.Signal(Player)
                OnRebirth()
            else if:
                Player := player[Interactor]
            then:
                Base_Setup.RebirthConfig.HudConfig.OnFailurePlayer(Player)
            



            
    }

    

    OnRebirth<override>():void=
        Owner.Config.Superlog("=== STARTING REBIRTH PROCESS ===")
        Owner.Config.Superlog("Current Status: {Status.ToStr()}")
        Owner.Config.Superlog("Current Players: {Players.Length}")

        # FIXED: Reset all purchaseables (this will reset their props)
        (GetPurchaseArray()).RebirthList(Self)

        # FIXED: Reset all currencies (this will reset ATM money to 0)
        for(Currency : Currencies)
        {
            Currency.OnRebirth()
        }

        Base_Setup.PurchaseableConfigs.OnRebirth()
        
        # CRITICAL FIX: Set status to unclaimed FIRST
        set Status = ClaimStatus.Unclaimed
        Owner.Config.Superlog("Status set to: {Status.ToStr()}")
        
        # CRITICAL FIX: Re-enable purchase zone with explicit status checks
        Base_Setup.PurchaseableConfigs.Purchase_Zone.Enable()
        Base_Setup.PurchaseableConfigs.Purchase_Zone.Show()
        Owner.Config.Superlog("Purchase zone re-enabled and shown")
        
        # CRITICAL FIX: Re-show and update billboard
        Base_Setup.BillBoardConfig.Show()
        Base_Setup.BillBoardConfig.Instantiate()
        Owner.Config.Superlog("Billboard re-shown and instantiated")
        
        set MoneyLeague = money_league{}

        # Get team collection for resetting player teams
        TC := Owner.GetPlayspace().GetTeamCollection()
        Teams := TC.GetTeams()

        # Process all players in the base
        for:
            Player:Players
            DelidCurrencies[Player, Base_Setup.PersistenceCore]
            DelidUnlocks[Player, Base_Setup.PersistenceCore]
            TempStats := Owner.GetPlayerStats[Player]
            
        do:
            TempStats.OnRebirth()
            Rebirth(Player, Base_Setup.PersistenceCore)
            Base_Setup.RebirthConfig.HudConfig.OnSuccessfullPlayer(Player)
            Base_Setup.RebirthConfig.RebirthAccolade.Award(Player)
            
            # FIXED: Move player to neutral team (Team 1, index 0) during rebirth
            if:
                Teams.Length > 0
                NeutralTeam := Teams[0]
            then:
                if(TC.AddToTeam[Player, NeutralTeam]):
                    Owner.Config.Superlog("Moved player to neutral team (index 0) during rebirth")
                else:
                    Owner.Config.Superlog("WARNING: Failed to move player to neutral team during rebirth")
            
            Owner.Config.Superlog("Processed rebirth for player")
            
        # CRITICAL FIX: Clear all player data
        set Players = array{}
        set RootPlayer = false
        Owner.Config.Superlog("Players array cleared, RootPlayer cleared")
        
        # CRITICAL FIX: Add base back to unclaimed list
        set Owner.UnclaimedBases += array{Self}
        Owner.Config.Superlog("Base added back to UnclaimedBases list. Total unclaimed: {Owner.UnclaimedBases.Length}")
        
        if:
            tempid := CreateID[15]
            set UniqueID = tempid
        then:
            Owner.Config.Superlog("Base ID is {UniqueID}")

        Owner.Config.Superlog("=== REBIRTH PROCESS COMPLETE ===")
        Owner.Config.Superlog("Final Status: {Status.ToStr()}")
        Owner.Config.Superlog("Final Players Count: {Players.Length}")

        return


    AwaitOnLeave()<suspends>:void=
        loop:
            Agent := LeaveButton.InteractedWithEvent.Await()
            if:
                Player := player[Agent]
                StatsMap := Owner.PlayerStatsMap[Player]?
                Players.Find[Player]
            then:
                StatsMap.OnLeave()

    #Initializes the base.
    Initialize<override>(Base:base, IX:int):void=
        #Set the base as unclaimed and enable all the Buy Zones again.
        set Status = ClaimStatus.Unclaimed
        set selfindex = IX
       

        spawn{AwaitOnLeave()}

        #Await for rebirths to be triggered.
        spawn{AwaitRebirth()}

        #Await for a player to enter the base and attempt to claim it.
        spawn{AwaitBaseClaim(IX)}

        if(ID := CreateID[15]){set UniqueID = ID}
        Owner.Config.Superlog("Base ID is {UniqueID}")

        
        Base_Setup.VFX.Initialize(Self)
        Base_Setup.SFX.Initialize(Self)
        Base_Setup.Initialize(Self)
        
       

        #For every purchaseable type in the base, initialize them.
        #Im not doing a multi-line for loop because a for loop can fail if one of the arrays is empty.
        for(I -> ICurrency: Currencies){ICurrency.Initialize(Self)}
        for(I ->ICollectable: Collectables){ICollectable.Initialize(Self)}
        for(I ->IGifts: Gifts){IGifts.Initialize(Self)}
        for(I ->IMoneywheel: MoneyWheel){IMoneywheel.Initialize(Self)}

        <#>
            New system after I talked to an epic employee and they actually fixed the issue 
            where you couldn't have an array of arrays of child classes even though they all shared a parent superclass.
            SOO NICHE but insane they did it 🙏🙏🙏 <3 Epic Games
        (GetPurchaseArray()).InitList(Self)

   



        

        


        
    #Returns the root player value for every player on the team as an array.
    #Adds a player to the team, if they aren't already on the Players list and the SizeLimit wont exceed.
    AddToTeam(Player:player)<transacts>:void=
        Owner.Config.Superlog("=== ADDING PLAYER TO TEAM ===")
        Owner.Config.Superlog("Base: {Base_Setup.Name}")
        Owner.Config.Superlog("Target Team Index: {Base_Setup.TeamToAddTo}")
        
        if:
            Players.Length < SizeLimit
        then:
            TC := Owner.GetPlayspace().GetTeamCollection()
            Teams := TC.GetTeams()
            
            Owner.Config.Superlog("Total teams available: {Teams.Length}")
            
            # Add to base's Players array
            set Players += array{Player}
            Owner.Config.Superlog("Added to base's Players array. New count: {Players.Length}")
            
            # CRITICAL FIX: Add to the correct Fortnite team with verification
            # Note: AddToTeam automatically handles moving from previous team
            if:
                Base_Setup.TeamToAddTo < Teams.Length
                TargetTeam := Teams[Base_Setup.TeamToAddTo]
            then:
                if:
                    TC.AddToTeam[Player, TargetTeam]
                then:
                    Owner.Config.Superlog("✓ Successfully added player to team index {Base_Setup.TeamToAddTo}")
                    
                    # Double-check it worked
                    if:
                        VerifyTeam := TC.GetTeam[Player]
                        VerifyTeam = TargetTeam
                    then:
                        Owner.Config.Superlog("✓ VERIFIED: Player is now on correct team!")
                    else:
                        Owner.Config.Superlog("✗ WARNING: Team verification failed!")
                else:
                    Owner.Config.Superlog("✗ CRITICAL ERROR: AddToTeam FAILED for team index {Base_Setup.TeamToAddTo}")
            else:
                Owner.Config.Superlog("✗ CRITICAL ERROR: Invalid team index {Base_Setup.TeamToAddTo} (max: {Teams.Length-1})")
        else:
            Owner.Config.Superlog("✗ Cannot add player: Size limit reached ({Players.Length}/{SizeLimit})")

    #Checks if a player is on the team and returns the index of the player in the Players list.
    (Player:player).IsOnTeam()<transacts><decides>:int={I := Players.Find[Player]; I}
        

    FindFirstPlayerOnTeam():?player={
        if: 
            Player := Players[0]
        then:
            option{Player}
        else:
            false
        }


        GetStringParams<override>(P:?player)<transacts>:[string]string=
            return map
            {
                "[Name]"=>Base_Setup.Name, 
                "[ID]"=>UniqueID, 
                "[Players.Length]"=>"{Players.Length}", 
                "SizeLimit"=>"{SizeLimit}", 
                "[Status]"=>"{Status.ToStr()}",
                "[FailureReason]"=>"{CFR.ToStr()}"
            }
