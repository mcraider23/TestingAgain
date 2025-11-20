using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using {cc}
using{Super}
<#
Developed by TSAR
ALL RIGHTS RESERVED
DO NOT SELL
#>

currency_ui<public>:=class():
    Player<public>:player
    Configs<public>:[]currency_ui_config  
    owner<public>:base

    var canvastodestory:canvas=canvas{}
    var StackBoxHoldings:[]stack_box_slot = array{}

    ManageUI<public>(CAM: [agent]?text_block, ID:?int)<suspends>:void=
        var timeout:int = 0
        timeoutlimit:int=100
        loop:
            Sleep(0.1);
            if:
                ActiveHud := CAM[Player]?
                ParsedID := ID?
                PlayerStats := GetCoreStats[Player, owner.Base_Setup.PersistenceCore]
                PlayerCurrency := PlayerStats.AssociatedCurrencies[ParsedID]
            then:
                ActiveHud.SetText(S2M("{PlayerCurrency.GetTrunc(owner)}"))
            else:
                GlobalSuperlog("Unable to attain stats")
                set timeout += 1
                if:
                    timeout >= timeoutlimit
                then:
                    Print("== WARNING MANAGING UI TIMED OUT AND FAILED FOR BASE: {owner.Base_Setup.Name} ==")

            if:
                GetRandomInt(0,1000) > 995
            then:
                CurrencyValue()
                #Prints the currency value, done random to not flood logs.

    ManagePS(CAM: []tuple([agent]?text_block, ?int, string))<suspends>:void=
        TotalPS := CAM.Length-1
        var X: int = 0
        loop:
            if:
                ActiveHud := CAM[0](0)[Player]?
                ParsedID := CAM[X](1)?
                Emoji := CAM[X](2)
                PerSecond := owner.MoneyLeague.PerSecond[ParsedID]
            then:
                ActiveHud.SetText(S2M("{Emoji} {PerSecond.GetTrunc(owner)} / sec")) 
            
            if(X = TotalPS){set X = 0}
            else{set X += 1}
                
            Sleep(1.85);

    # NEW METHOD: Manages the rebirth counter display for this player
    ManageRebirthUI<public>(RebirthTextBlock: [agent]?text_block)<suspends>:void=
        var timeout:int = 0
        timeoutlimit:int=100
        loop:
            Sleep(0.1)
            if:
                ActiveHud := RebirthTextBlock[Player]?
                PlayerStats := GetCoreStats[Player, owner.Base_Setup.PersistenceCore]
                RebirthCount := PlayerStats.Rebirths
            then:
                ActiveHud.SetText(S2M("{RebirthCount}"))
            else:
                GlobalSuperlog("Unable to attain rebirth stats")
                set timeout += 1
                if:
                    timeout >= timeoutlimit
                then:
                    Print("== WARNING MANAGING REBIRTH UI TIMED OUT FOR BASE: {owner.Base_Setup.Name} ==")

            if:
                GetRandomInt(0,1000) > 995
            then:
                GlobalSuperlog("Rebirth UI Update Check")

    # NEW METHOD: Manages the income bonus multiplier display
    ManageIncomeBonusUI<public>(BonusTextBlock: [agent]?text_block)<suspends>:void=
        var timeout:int = 0
        timeoutlimit:int=100
        loop:
            Sleep(0.1)
            if:
                ActiveHud := BonusTextBlock[Player]?
                PlayerStats := GetCoreStats[Player, owner.Base_Setup.PersistenceCore]
                RebirthCount := PlayerStats.Rebirths
                # Calculate the bonus percentage (10% per rebirth)
                BonusPercentage := RebirthCount * 10
            then:
                ActiveHud.SetText(S2M("+{BonusPercentage}%"))
            else:
                GlobalSuperlog("Unable to attain income bonus stats")
                set timeout += 1
                if:
                    timeout >= timeoutlimit
                then:
                    Print("== WARNING MANAGING INCOME BONUS UI TIMED OUT FOR BASE: {owner.Base_Setup.Name} ==")

    Destroy<public>():void=
        if:
            PlayerHud := GetPlayerUI[Player]
        then:
            PlayerHud.RemoveWidget(canvastodestory)

    Create<public>():void=
        var AddedPS:logic=false
        var PerSecondRotations: []tuple([agent]?text_block, ?int, string) = array{}
        
        # Create Currency Overlays (existing code)
        Overlays := for:
            Config:Configs
        do:
            ActiveCash := text_block:
                DefaultText := S2M("0")
                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}

            ActivePS := text_block:
                DefaultText := S2M("")
                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}

            var CurrencyAmount: [agent]?text_block = map{}
            if(set CurrencyAmount[Player] = option{ActiveCash}){}
            spawn{ManageUI(CurrencyAmount, Config.CurrencyID)}

            var PerSecond: [agent]?text_block = map{}
            if(set PerSecond[Player] = option{ActivePS}){}

            StackWidget := overlay:
                Slots := array:
                    overlay_slot:
                        Widget := texture_block:
                            DefaultImage := StroklessBG
                            DefaultTint := Config.Backgroundcolor
                            DefaultDesiredSize := vector2{X:=32.0, Y:=55.0}
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Right:=5.0}

                    overlay_slot:
                        Widget := text_block:
                            DefaultText := S2M("{Config.Emoji}")
                            DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                        HorizontalAlignment := horizontal_alignment.Left
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Left:=11.0, Right:=35.0}

                    overlay_slot:
                        Widget := text_block:
                            DefaultText := S2M("{Config.AlphaText}")
                            DefaultTextOpacity := Config.AlphaOpcaity
                            DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Left:=11.0, Right:=40.0}

                    overlay_slot:
                        Widget := ActiveCash
                        HorizontalAlignment := horizontal_alignment.Right
                        VerticalAlignment := vertical_alignment.Center
                        Padding:=margin{Left:=11.0, Right:=60.0}
            
            if:
                Config.ShowPerSecond?
                AddedPS?
            then:
                set PerSecondRotations += array{(PerSecond, Config.CurrencyID, Config.Emoji)}
                GlobalSuperlog("Second+ Rev Rotation Added")

            if:
                Config.ShowPerSecond?
                not AddedPS?
            then:
                set AddedPS = true
                set StackBoxHoldings += array:
                    stack_box_slot:
                        Widget := ActivePS
                        HorizontalAlignment := horizontal_alignment.Right
                        VerticalAlignment := vertical_alignment.Bottom
                        Padding:=margin{Right:=40.0}
                set PerSecondRotations += array{(PerSecond, Config.CurrencyID, Config.Emoji)}
                GlobalSuperlog("Initial Rev Rotation Added")

            StackWidget
        
        GlobalSuperlog("Begun Updating Per Second Rev Rotations") 
        spawn{ManagePS(PerSecondRotations)}
        
        for:
            Overlay:Overlays
        do:
            set StackBoxHoldings += array:
                stack_box_slot:
                    Widget:=Overlay
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Top

        # NOW Add Rebirth Counter and Income Bonus AFTER currencies
        
        # Create Rebirth Counter Display
        RebirthText := text_block:
            DefaultText := S2M("0")
            DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}

        var RebirthTextMap: [agent]?text_block = map{}
        if(set RebirthTextMap[Player] = option{RebirthText}){}
        spawn{ManageRebirthUI(RebirthTextMap)}

        # Add Rebirth Counter to the UI stack
        set StackBoxHoldings += array:
            stack_box_slot:
                Widget:=overlay:
                    Slots := array:
                        overlay_slot:
                            Widget := texture_block:
                                DefaultImage := StroklessBG
                                DefaultTint := color{R:=0.5, G:=0.2, B:=0.8}  # Purple background
                                DefaultDesiredSize := vector2{X:=32.0, Y:=55.0}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Right:=5.0}
                        overlay_slot:
                            Widget := text_block:
                                DefaultText := S2M("💸")  # Rebirth emoji
                                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                            HorizontalAlignment := horizontal_alignment.Left
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Left:=11.0, Right:=35.0}
                        overlay_slot:
                            Widget := text_block:
                                DefaultText := S2M("Rebirths")
                                DefaultTextOpacity := 0.75
                                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Left:=11.0, Right:=40.0}
                        overlay_slot:
                            Widget := RebirthText
                            HorizontalAlignment := horizontal_alignment.Right
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Left:=11.0, Right:=60.0}
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Top

        # Create Income Bonus Display
        IncomeBonusText := text_block:
            DefaultText := S2M("+0%")
            DefaultTextColor := color{R:=0.2, G:=1.0, B:=0.2}  # Bright green for bonus

        var IncomeBonusTextMap: [agent]?text_block = map{}
        if(set IncomeBonusTextMap[Player] = option{IncomeBonusText}){}
        spawn{ManageIncomeBonusUI(IncomeBonusTextMap)}

        # Add Income Bonus Multiplier to the UI stack
        set StackBoxHoldings += array:
            stack_box_slot:
                Widget:=overlay:
                    Slots := array:
                        overlay_slot:
                            Widget := texture_block:
                                DefaultImage := StroklessBG
                                DefaultTint := color{R:=0.1, G:=0.6, B:=0.2}  # Green background
                                DefaultDesiredSize := vector2{X:=32.0, Y:=55.0}
                            HorizontalAlignment := horizontal_alignment.Fill
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Right:=5.0}
                        overlay_slot:
                            Widget := text_block:
                                DefaultText := S2M("💰")  # Money bag emoji
                                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                            HorizontalAlignment := horizontal_alignment.Left
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Left:=11.0, Right:=35.0}
                        overlay_slot:
                            Widget := text_block:
                                DefaultText := S2M("Bonus")
                                DefaultTextOpacity := 0.75
                                DefaultTextColor := color{R:=1.000000, G:=1.000000, B:=1.000000}
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Left:=11.0, Right:=40.0}
                        overlay_slot:
                            Widget := IncomeBonusText
                            HorizontalAlignment := horizontal_alignment.Right
                            VerticalAlignment := vertical_alignment.Center
                            Padding:=margin{Left:=11.0, Right:=60.0}
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Top

        # Calculate bottom position - now includes rebirth counter and bonus display
        var FindBottom : float = 80.0 + (125.0*StackBoxHoldings.Length-2.0)

        # Assign the UI to the player
        CurrencyStackBox:=stack_box:
            Orientation := orientation.Vertical
            Slots:=for:
                Overlay:StackBoxHoldings
            do:
               Overlay
        
        CanvasPanel:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=CurrencyStackBox
                    Anchors:=anchors{Minimum:=vector2{X:=0.012625,Y:=0.291111}, Maximum:=vector2{X:=0.214375,Y:=0.271111}}
                    Offsets := margin{Bottom := FindBottom}
                    SizeToContent := false
        
        if:
            PlayerHud := GetPlayerUI[Player]
        then:
            PlayerHud.AddWidget(CanvasPanel)
            set canvastodestory = CanvasPanel

currency_ui_config<public>:=class<public><concrete>():
    @editable CurrencyID : ?int = option{0}
    @editable Emoji : string = "🤑"
    @editable AlphaText : string = "Dollars"
    @editable AlphaOpcaity : type {_X:float where 0.15 <= _X, _X <= 0.85} = 0.75
    @editable ShowPerSecond: logic = false
    @editable Backgroundcolor : color = color{R:=0.000000, G:=0.464583, B:=0.028349}