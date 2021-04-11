:- include('web.pl').

check_credit_count(Transcript) :-
    credit_count_helper(Transcript, CreditList),
    credit_sum(CreditList, Sum),
    Sum > 119,
    writeln("Credit Requirement is Satisfied."),

credit_count_helper([],[]).
credit_count_helper([H|T],[C|L]) :-
    split_string(H, " ", "" , Tokens),
    nth0(0, Tokens, SubjectCode),
    nth0(1, Tokens, SubjectNum),
    credit(SubjectCode,SubjectNum, C),
    credit_count_helper(T, L).

credit_sum([],0).
credit_sum([H|T],Sum) :-
    credit_sum(T, XSum),
    Sum is H + XSum.


check_comm_req(Transcript, ModifiedTranscript) :-
    get_comm_course(Transcript, CommCourses),
    length(CommCourses, Length),
    Length > 1,
    remove_courses(Transcript, CommCourses, ModifiedTranscript, 2).   
    

% remove_courses returns true when ModifiedTranscript is a list
% of the elements in Transcript but with N elements less.
% The removed elements from Transcript are the first N elements
% in RemoveList.
% e.g) remove_courses(["CPSC 410", "ENGL 110", "ENGL 111"], ["ENGL 110", "ENGL 111"], MT, 2).
% MT = ["CPSC 410"]
remove_courses(Transcript,[],Transcript,_).
remove_courses(Transcript,[_|_],Transcript,N) :- N < 1.
remove_courses([H|T1],[X|Y],[H|R],N) :- 
    N > 0,
    \+member(H, [X|Y]),
    remove_courses(T1, [X|Y], R, N).
remove_courses([H|T1],[X|Y],R,N) :-
    N > 0,
    NX is N-1,
    member(H, [X|Y]),
    remove_courses(T1, [X|Y], R, NX).


% Takes a transcript and returns
% a list of communciation courses in the transcript
get_comm_course(Transcript, L) :-
    findall(
        X,
        (member(X,Transcript), communication_course(X)),
        L).


% Takes a course string (e.g CPSC 410) and sets
% SubjectCode and SubjectNum
% e.g) get_course_info("CPSC 410", SC, SN).
% SC = CPSC
% SN = 410
get_course_info(Course, SubjectCode, SubjectNum) :-
    split_string(Course, " ", "" , Tokens),
    nth0(0, Tokens, SubjectCode),
    nth0(1, Tokens, SubjectNum).


communication_course("WRDS 150").
communication_course("SCIE 113").
communication_course("ENGL 100").
communication_course("ENGL 110").
communication_course("ENGL 111").
communication_course("ENGL 112").
communication_course("ENGL 120").
communication_course("ENGL 121").
communication_course("SCIE 300").







% TODO
check_core_req(Transcript, ModifiedTranscript).

% TODO
check_arts_req(Transcript, ModifiedTranscript).

% check_breadth_req(["MATH 100","CHEM 101","PHYS 101","BIOL 100","STAT 100","CPSC 100","ASTR 100"], MT).
check_breadth_req(TR, MT):-
    check_breadth_general(TR, MT1, "CHEM", N1),
    check_breadth_general(MT1, MT2, "PHYS", N2),
    check_breadth_LFSC(MT2, MT3, N3),
    check_breadth_EPSC(MT3, MT4, N4),
    Total1 is N1+N2+N3,
    Total2 is N1+N2+N3+N4,
    Total2 > 2,
    (   Total1 > 3
    ->  MT = MT3
    ;   Total2 > 3
    ->  MT = MT4
    ;   MT = TR 
    ),
    writeln("Breadth Requirement is Satisfied.").
    

check_breadth_LFSC(TR, MT, N) :-
    check_breadth_general(TR, MT1, "BIOL", N1),
    check_breadth_general(TR, MT2, "BIOC", N2),
    check_breadth_general(TR, MT3, "PSYC", N3),
    check_breadth_general(TR, MT4, "MICB", N4),
    check_breadth_edge(TR, MT5, "GEOB 207", N5),
    get_first_MT([MT1, MT2, MT3, MT4, MT5], [N1, N2, N3, N4, N5], TR, MT, N).


check_breadth_STAT(TR, MT, N) :-
    check_breadth_general(TR, MT1, "STAT", N1),
    check_breadth_edge(TR, MT2, "BIOL 300", N2),
    check_breadth_edge(TR, MT3, "DSCI 100", N3),
    check_breadth_edge(TR, MT4, "MATH 302", N4),
    get_first_MT([MT1, MT2, MT3, MT4], [N1, N2, N3, N4], TR, MT, N).


check_breadth_EPSC(TR, MT, N) :-
    check_breadth_general(TR, MT1, "ASTR", N1),
    check_breadth_general(TR, MT2, "ATSC", N2),
    check_breadth_general(TR, MT3, "ENVR", N3),
    check_breadth_general(TR, MT4, "EOSC", N4),
    check_breadth_general(TR, MT5, "GEOB", N5),
    get_first_MT([MT1, MT2, MT3, MT4, MT5], [N1, N2, N3, N4, N5], TR, MT, N).


% returns the first MT that was changed
get_first_MT([MT1|T1], [N1|T2], TR, MT, N) :-
    (   N1 > 0
    ->  N = N1, MT = MT1
    ;   get_first_MT(T1, T2, TR, MT, N)
    ).
get_first_MT([], [], TR, TR, 0).


% checks if the specific course is in the transcript and removes it
check_breadth_edge(TR, MT, CourseName, N) :-
    (   member(CourseName, TR)
    ->  N = 1, remove_courses(TR, [CourseName], MT, 1)
    ;   N = 0, MT = TR
    ).
     

% returns the modified transcript if there is a satisfactory course with specified subject
check_breadth_general(TR, MT, Category, N) :-
    breadth_helper(TR, Result, Category),
    remove_courses(TR, Result, MT, 1),
    length(Result, Len),
    (   Len > 0
    ->  N = 1
    ;   N = 0
    ).

% breadth_helper(["CPSC 100", "BIOL 300"], Result, "BIOL").
% Result = [] ;
breadth_helper([],[],_).
breadth_helper([H|T],L,Category) :-
    invalid_breadth_courses(H),
    breadth_helper(T, L, Category).
breadth_helper([H|T],L,Category) :-
    split_string(H, " ", "" , Tokens),
    nth0(0, Tokens, SubjectCode),
    dif(SubjectCode, Category),
    breadth_helper(T, L, Category).
breadth_helper([H|T],[H|L],Category) :-
    \+invalid_breadth_courses(H),
    split_string(H, " ", "" , Tokens),
    nth0(0, Tokens, Category),
    breadth_helper(T, L, Category).

invalid_breadth_courses("MATH 302").
invalid_breadth_courses("CHEM 100").
invalid_breadth_courses("CHEM 300").
invalid_breadth_courses("PHYS 100").
invalid_breadth_courses("BIOL 140").
invalid_breadth_courses("BIOL 300").
invalid_breadth_courses("EOSC 111").
invalid_breadth_courses("GEOB 207").


% TODO
% electives requirement
check_elect_req(Transcript).
