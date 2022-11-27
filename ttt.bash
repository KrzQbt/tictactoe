#!/bin/bash
show_board () {
    echo current board:
    echo "| " "${board[0]}" " | " "${board[1]}" " | " "${board[2]}" " |"
    echo "| " "${board[3]}" " | " "${board[4]}" " | " "${board[5]}" " |"
    echo "| " "${board[6]}" " | " "${board[7]}" " | " "${board[8]}" " |"
}

show_moves_left() {
    echo -n possible choices :
    for i in "${movesLeftSet[@]}"
    do
        echo -n "$i " 
    done
    echo ""

}

checkIfMoveIsAllowed() {
    if [[ "$nextMove" == "$saveCommand" ]]; then
        echo saving...
        echo -n "${movesLeftSet[@]}" > ./movesleft.txt
        echo -n "${board[@]}" > ./board.txt
        echo -n $turn > ./turn.txt
        echo saved, bye!
        exit 0
    fi

    for i in "${movesLeftSet[@]}"
    do
        if [[ "$i" == "$nextMove" ]]; then
            moveAllowed=true
            break;
        else
            moveAllowed=false
            
        fi
    done
    if [[ "$moveAllowed" == false ]]; then
        clear
        echo Not allowed move! Pick again...
    fi
}

changewhosTurn(){
if [[ "$turn" == "$xTurn" ]]; then
    turn="Y"
else
    turn="X"
fi

}


remove_last_move_from_allowed() {
    # https://unix.stackexchange.com/questions/328882/how-to-add-remove-an-element-to-from-the-array-in-bash
    buffSet=()
    for i in "${movesLeftSet[@]}"
    do
        if [[ "$i" != "$nextMove" ]]; then
            buffSet+=($i)
        fi
    done
    movesLeftSet=(${buffSet[@]})

}

win_check() {

    # winCombos row 123 456 789 
    if [ "${board[0]}" == "$turn" ] && [ "${board[1]}" == "$turn" ] && [ "${board[2]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

    if [ "${board[3]}" == "$turn" ] && [ "${board[4]}" == "$turn" ] && [ "${board[5]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

    if [ "${board[6]}" == "$turn" ] && [ "${board[7]}" == "$turn" ] && [ "${board[8]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

    # winCombos col 147 258 369
    if [ "${board[0]}" == "$turn" ] && [ "${board[3]}" == "$turn" ] && [ "${board[6]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

    if [ "${board[1]}" == "$turn" ] && [ "${board[4]}" == "$turn" ] && [ "${board[7]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

    if [ "${board[2]}" == "$turn" ] && [ "${board[5]}" == "$turn" ] && [ "${board[8]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi
    
    # winCombos diag 158 357
    if [ "${board[0]}" == "$turn" ] && [ "${board[4]}" == "$turn" ] && [ "${board[8]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

    if [ "${board[2]}" == "$turn" ] && [ "${board[4]}" == "$turn" ] && [ "${board[6]}" == "$turn" ]; then
           won=true
           winner=$turn
    fi

}


set_allowed_false() {
    moveAllowed=false
}


submit_next_move() {
    board[nextMove-1]=$turn
    set_allowed_false
    
    remove_last_move_from_allowed
    win_check
    no_more_moves_check
    changewhosTurn
}

no_more_moves_check() {
    if [[ ${#movesLeftSet[@]} == 0  ]]; then
        noMoreMoves=true
    fi
}




# args capture, https://opensource.com/article/21/8/option-parsing-bash

if [ "$1" = "-h"  ]; then
    echo Tic tac toe. To stat run with no options. To resume game run with with option -c
    exit 0
fi

if [ "$1" = "-c"  ]; then
    continued=true
    read -a board < ./board.txt
    read -a movesLeftSet < ./movesleft.txt
    turn=$(head -n 1 ./turn.txt)
    echo $turn
else
    
    continued=false
    turn="X" # keep track of whos turn
    board=("1" "2" "3" "4" "5" "6" "7" "8" "9")
    movesLeftSet=("1" "2" "3" "4" "5" "6" "7" "8" "9")
fi

saveCommand="save";
xTurn="X" # x turn const
yTurn="Y" # y turn const
started=true
nextMove=""
moveAllowed=false
won=false
winner=""
noMoreMoves=false
resumed=false

echo Started game with $turn turn! 


while [ "$started" = "true" ]
do

    while [ "$moveAllowed" = false ]
    do  
        if [[ "$continued" == true ]]; then
            if [[ "$resumed" == false ]]; then
            
                if [[ "$turn" == "$xTurn" ]]; then
                    resumed=true
                    continued=false
                    
                else
                    
                    break;
                fi
            fi
            
        fi
        if [[ "$noMoreMoves" == true ]]; then
            
            break;
        fi
        
        show_board
        show_moves_left
        
        read -p "Player 1 (X), pick next spot number or type save: " nextMove
        checkIfMoveIsAllowed
    done

    if [[ "$resumed" == true ]]; then
        submit_next_move        
    fi
    

    win_check
    if [[ "$won" == true ]]; then
            
            break;
    fi
    # clear
 
    while [ "$moveAllowed" = "false" ]
    do
        if [[ "$noMoreMoves" == true ]]; then
            
            break;
        fi
        resumed=true
        show_board
        show_moves_left
        read -p "Player 2 (Y), pick next spot number or type save: " nextMove
        checkIfMoveIsAllowed
        
    done

    if [[ "$noMoreMoves" == true ]]; then
            
            break;
        fi

    submit_next_move
    win_check
    if [[ "$won" == true ]]; then
            
            break;
    fi
    clear

done







while [ "$continued" = "true" ]
do

    while [ "$moveAllowed" = false ]
    do
        if [[ "$resumed" == false ]]; then
            if [[ "$turn" == false ]]; then
            
                break;
            fi
            break;
        fi

        if [[ "$noMoreMoves" == true ]]; then
            
            break;
        fi
        
        show_board
        show_moves_left
        read -p "Player 1 (X), pick next spot number: " nextMove
        checkIfMoveIsAllowed
    done
    
    submit_next_move
    win_check
    if [[ "$won" == true ]]; then
            
            break;
    fi
    clear
 
    while [ "$moveAllowed" = "false" ]
    do
        if [[ "$noMoreMoves" == true ]]; then
            
            break;
        fi
        resumed=true

        show_board
        show_moves_left
        read -p "Player 2 (Y), pick next spot number: " nextMove
        checkIfMoveIsAllowed
        
    done

    if [[ "$noMoreMoves" == true ]]; then
            
            break;
        fi

    submit_next_move
    win_check
    if [[ "$won" == true ]]; then
            
            break;
    fi
    clear

done




echo end
if [[ "$won" == true ]]; then
    echo THE WINNER IS $winner!!!            
fi

show_board
