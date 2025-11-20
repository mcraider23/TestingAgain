using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Teams }

billboard_facing_device := class(creative_device):
    @editable
    Billboards : []billboard_device = array{}
    
    @editable
    RotationLerpSpeed : float = 0.2
    
    @editable
    TargetTeamIndex : int = 1  # Set to 1, 2, 3, or 4 for each player's team
    
    @editable
    EnableTeamFiltering : logic = true  # Toggle to disable team filtering if needed

    # Track hidden state to only log on change
    var HiddenStates : []logic = array{}
    
    # Store reference to the target team
    var TargetTeam : ?team = false

    OnBegin<override>()<suspends> : void =
        # Initialize hidden state array
        set HiddenStates = for (Index := 0..Billboards.Length - 1):
            false
        
        # Get reference to the target team by index
        TeamCollection := GetPlayspace().GetTeamCollection()
        AllTeams := TeamCollection.GetTeams()
        if (TargetTeamIndex > 0, TargetTeamIndex <= AllTeams.Length):
            set TargetTeam = option{AllTeams[TargetTeamIndex - 1]}

        loop:
            UpdateBillboardRotations()
            Sleep(0.0)

    UpdateBillboardRotations() : void =
        if (Players := GetPlayspace().GetPlayers(), Players.Length > 0):
            # Find target player
            var TargetPlayer : ?player = false
            
            if (EnableTeamFiltering?):
                if (TeamToCheck := TargetTeam?):
                    # Find first player on the target team
                    TeamCollection := GetPlayspace().GetTeamCollection()
                    for (Player : Players):
                        if (PlayerTeam := TeamCollection.GetTeam[Player]):
                            # Compare team objects directly
                            if (PlayerTeam = TeamToCheck):
                                set TargetPlayer = option{Player}
            else:
                # Use first player if team filtering is disabled
                set TargetPlayer = option{Players[0]}
            
            # Only proceed if we found a valid target player
            if (Player := TargetPlayer?):
                if (Character := Player.GetFortCharacter[]):
                    PlayerPos := Character.GetTransform().Translation
                    for (Index := 0..Billboards.Length - 1):
                        if (Billboard := Billboards[Index]):
                            CurrentTransform := Billboard.GetTransform()
                            BillboardPos := CurrentTransform.Translation
                            # Track and report state changes only
                            if (BillboardPos.Z > -10000.0):
                                if (HiddenStates[Index] = true):
                                    if (set HiddenStates[Index] = false):
                                        Print("Billboard {Index} became visible")
                                Direction := vector3{
                                    X := PlayerPos.X - BillboardPos.X, 
                                    Y := PlayerPos.Y - BillboardPos.Y, 
                                    Z := 0.0
                                }
                                if (Direction.Length() > 0.0):
                                    Forward := vector3{X := 0.0, Y := 1.0, Z := 0.0}
                                    TargetRotation := MakeShortestRotationBetween(Forward, Direction)
                                    if (NewRotation := Slerp[CurrentTransform.Rotation, TargetRotation, RotationLerpSpeed]):
                                        if (Billboard.TeleportTo[CurrentTransform.Translation, NewRotation]) { }
                            else:
                                if (HiddenStates[Index] = false):
                                    if (set HiddenStates[Index] = true):
                                        Print("Billboard {Index} considered hidden, skipping teleport")