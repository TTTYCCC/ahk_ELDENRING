#Requires AutoHotkey v2.0
ProcessSetPriority("High")
SendMode "Input"
SetKeyDelay(-1, -1)

PracticalDodgeKey := "Space"
PracticalDashKey := "LShift"
InGameDodgeKey := "I"

Dodgedown := "{" InGameDodgeKey " down}"
Dodgeup := "{" InGameDodgeKey " up}"

ct := 20    ;翻滚启动时间，毫秒
dct := 30   ;奔跑翻滚启动时间
dashnt := 50   ;奔跑翻滚后奔跑启动时间
dashct := 50    ;移动检测时间间隔

DefaultMode := 1    ;默认模式
SetMode(DefaultMode)
global Mode := DefaultMode
global IsDashing := false  ;检测奔跑
HotIfWinActive("ELDEN RING™")
    Hotkey "*" . PracticalDodgeKey, Dodge
    Hotkey "*" . PracticalDashKey, Dash
    ;选择操作模式,alt+数字键切换，1默认 2切换奔跑+长按翻滚闪避一次后奔跑 3切换奔跑+长按一直滚 4按住奔跑+长按跑 5按住奔跑+长按滚
    !1:: SetMode(1)
    !2:: SetMode(2)
    !3:: SetMode(3)
    !4:: SetMode(4)
    !5:: SetMode(5)
HotIfWinActive
Dodge(*)    ; 翻滚
{
    if Mode != 1{
        if IsDashing {
            Send Dodgeup
            Sleep dct
        }
        
        Send Dodgedown
        Sleep ct
        Send Dodgeup
        
        if Mode == 2 || Mode == 4
        {
            if IsDashing
            {
                Sleep dashnt
                Send Dodgedown
                KeyWait PracticalDodgeKey
            }
            else    ;长按时冲刺
            {
                Sleep dashnt
                StartTime := A_TickCount
                KeyWait PracticalDodgeKey, "T0.1"
                if A_TickCount-StartTime >= 100
                {
                    Send Dodgedown
                    KeyWait PracticalDodgeKey
                    Send Dodgeup
                }
            }
        } else{
            if IsDashing
            {
                Sleep dashnt
                Send Dodgedown
            }
        }

    } else{
        Send Dodgedown
        KeyWait PracticalDodgeKey
        Send Dodgeup
    }
}
Dash(*)     ; 奔跑
{
    if Mode != 1{
        global IsDashing
        if Mode == 2 || Mode == 3
        {
            if !IsDashing {
                ; 如果还没在冲刺，且有在移动
                if GetKeyState("w","P") || GetKeyState("a","P") || GetKeyState("s","P") || GetKeyState("d","P") {
                    Send Dodgedown
                    IsDashing := true
                    ; 启动定时检查
                    SetTimer CheckMovement, dashct
                }
            }else {
                ; 如果已经在冲刺，则停止
                Send Dodgeup
                IsDashing := false
                SetTimer CheckMovement, 0
            }
        } else{
            if GetKeyState("w","P") || GetKeyState("a","P") || GetKeyState("s","P") || GetKeyState("d","P")
            {
                Send Dodgedown
                IsDashing := true
                StartTime := A_TickCount
                KeyWait PracticalDashKey
                RemainedTime := 500 - A_TickCount + StartTime
                if (RemainedTime > 0)
                {
                    Sleep RemainedTime
                }
                Send Dodgeup
                IsDashing := false
            }
            
        }

    }
}
CheckMovement()     ;移动检测，不动时关闭奔跑
{
    global IsDashing
    if !GetKeyState("w","P") && !GetKeyState("a","P") && !GetKeyState("s","P") && !GetKeyState("d","P")
    {
        Send Dodgeup
        IsDashing := false
        SetTimer CheckMovement, 0
    }
}
SetMode(newMode)
{
    Send Dodgeup
    global IsDashing
    global Mode
    IsDashing := false
    Mode := newMode
    SetTimer CheckMovement, 0 
}