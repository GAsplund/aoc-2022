Open "input.txt" For Input Encoding "ascii" As #1
Dim fileLen As LongInt = Lof(1)
Dim puzzleinput As String = Space(fileLen)
Get #1, 1, puzzleinput

Function CheckUnique (DataIn As String, Start As Integer, Length As Integer) As Integer
    For i As Integer = Start To Start+Length-1 '' Check each character
        For j As Integer = i+1 To Start+Length-1 '' Scan for each character after i
            If DataIn[i] = DataIn[j] Then
                Return 0
            End If
        Next j
    Next i
    Return 1
End Function

Function FindUnique (DataIn As String, NumUnique As Integer) As Integer
    '' Check if requested length is longer than desired string
    If NumUnique > len(DataIn) Then
        Return -1
    End If

    For i As Integer = 0 To Len(DataIn)-NumUnique
        If CheckUnique(DataIn, i, NumUnique) = 1 Then
            Return i+NumUnique
        End If
    Next i

    '' Couldn't find
    Print("Unable to find")
    Return -1
End Function

Print "Solution 1: ";Str(FindUnique(puzzleinput, 4))
Print "Solution 2: ";Str(FindUnique(puzzleinput, 14))

buffer = ""  '' Release memory used by buffer
Close #1

End
