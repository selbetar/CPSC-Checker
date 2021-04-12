:- include('web.pl').

check_credit_count(Transcript) :-
    credit_count_helper(Transcript, CreditList),
    credit_sum(CreditList, Sum),
    Sum > 119,
    write("Credit Requirement is Satisfied.\n").

credit_count_helper([],[]).
credit_count_helper([H|T],[C|L]) :-
    get_course_info(H, SC, SN),
    credit(SC,SN, C),
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

/*
check_core_req(["CPSC 110", "CPSC 121", "MATH 100", "MATH 101", "CHEM 121", "PHYS 101", "BIOL 121", "CPSC 210",
"CPSC 213", "CPSC 221", "MATH 200", "MATH 221", "STAT 241", "CPSC 310", "CPSC 313", "CPSC 320", "CPSC 304",
"CPSC 312", "CPSC 340", "CPSC 404", "CPSC 410", "CPSC 416"], MT).
*/
check_core_req(Transcript, ModifiedTranscript) :-
    check_first_year_core_req(Transcript, MT1),
    check_second_year_core_req(MT1, MT2),
    check_upper_year_core_req(MT2, ModifiedTranscript).


% check_first_year_core_req(["CPSC 110", "CPSC 121", "MATH 100", "MATH 101", "CHEM 121", "PHYS 101", "BIOL 121"], MT).
check_first_year_core_req(Transcript, ModifiedTranscript) :-
    check_first_year_cpsc_req(Transcript, MT1),
    check_first_year_math_req(MT1, ModifiedTranscript),
    write("First Year Core Requirement is Satisfied.\n").


% check_first_year_cpsc_req(["CPSC 110", "CPSC 121", "CPSC 210"], MT).
check_first_year_cpsc_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), first_year_cpsc(X)), L1),
    length(L1, Length),
    Length > 1,
    remove_courses(Transcript, L1, ModifiedTranscript, 2).

first_year_cpsc("CPSC 110").
first_year_cpsc("CPSC 121").


% check_first_year_math_req(["MATH 102", "MATH 103", "MATH 200"], MT).
check_first_year_math_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), first_year_math1(X)), L1),
    findall(Y, (member(Y, Transcript), first_year_math2(Y)), L2),
    length(L1, Length1),
    length(L2, Length2),
    Length1 > 0,
    Length2 > 0,
    first_year_math_helper(L1, L2, MathCourses),
    remove_courses(Transcript, MathCourses, ModifiedTranscript, 2).

% returns a list containing one item from the first list and one item from the second list
first_year_math_helper([],[],_).
first_year_math_helper([H1|_], [H2|_], L) :-
    L = [H1,H2].

first_year_math1("MATH 100").
first_year_math1("MATH 102").
first_year_math1("MATH 104").
first_year_math1("MATH 110").
first_year_math1("MATH 111").
first_year_math1("MATH 120").
first_year_math1("MATH 140").
first_year_math1("MATH 180").
first_year_math1("MATH 184").

first_year_math2("MATH 101").
first_year_math2("MATH 103").
first_year_math2("MATH 105").
first_year_math2("MATH 121").


% check_phys_science_req(["MATH 100", "PHYS 101", "CPSC 110", "CHEM 121"], MT).
check_phys_science_req(Transcript, ModifiedTranscript) :-
    get_phys_science_courses(Transcript, PhysSciCourses),
    length(PhysSciCourses, Length),
    Length > 1,
    remove_courses(Transcript, PhysSciCourses, ModifiedTranscript, 2).

% Gets physical science (CHEM or PHYS) courses from transcript
% get_phys_science_courses(["MATH 100", "PHYS 101", "CPSC 110", "CHEM 121"], L).
get_phys_science_courses(Transcript, L) :-
    findall(X, (member(X,Transcript), phys_science_course(X)), L).

% returns true for eligible first year physical science courses (CHEM 100 and PHYS 100 are invalid)
phys_science_course(Course) :-
    get_course_info(Course, SC, SN),
    SC = "CHEM",
    atom_number(SN, Num),
    Num > 100,
    Num < 200.
phys_science_course(Course) :-
    get_course_info(Course, SC, SN),
    SC = "PHYS",
    atom_number(SN, Num),
    Num > 100,
    Num < 200.


% check_biol_req(["MATH 100", "BIOL 121", "CPSC 110"], MT).
check_biol_req(Transcript, ModifiedTranscript) :-
    get_biol_courses(Transcript, BiolCourses),
    length(BiolCourses, Length),
    Length > 0,
    remove_courses(Transcript, BiolCourses, ModifiedTranscript, 1).

% Gets biology requirement courses from transcript
% get_biol_courses(["MATH 100", "BIOL 121", "CPSC 110"], L).
get_biol_courses(Transcript, L) :-
    findall(X, (member(X, Transcript), biol_course(X)), L).

% returns true for eligible biology courses (ASTR, ATSC, BIOL, EOSC, GEOB)
biol_course(Course) :-
    get_course_info(Course, SC, _),
    member(SC, ["ASTR", "ATSC", "BIOL", "EOSC", "GEOB"]).


% check_second_year_core_req(["CPSC 210", "CPSC 213", "CPSC 221", "MATH 200", "MATH 221", "STAT 241"], MT).
check_second_year_core_req(Transcript, ModifiedTranscript) :-
    check_second_year_cpsc_req(Transcript, MT1),
    check_second_year_math_req(MT1, MT2),
    check_second_year_stat_req(MT2, ModifiedTranscript),
    write("Second Year Core Requirement is Satisfied.\n").


% check_second_year_cpsc_req(["CPSC 210", "CPSC 213", "CPSC 221", "CPSC 310"], MT).
check_second_year_cpsc_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), second_year_cpsc(X)), CpscCourses),
    length(CpscCourses, Length),
    Length > 2,
    remove_courses(Transcript, CpscCourses, ModifiedTranscript, 3).

second_year_cpsc("CPSC 210").
second_year_cpsc("CPSC 213").
second_year_cpsc("CPSC 221").


% check_second_year_math_req(["MATH 200", "MATH 221"], MT).
check_second_year_math_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), second_year_math(X)), MathCourses),
    length(MathCourses, Length),
    Length > 1,
    remove_courses(Transcript, MathCourses, ModifiedTranscript, 2).

second_year_math("MATH 200").
second_year_math("MATH 221").


% check_second_year_stat_req(["STAT 200", "MATH 302"], MT).
% check_second_year_stat_req(["STAT 251"], MT).
check_second_year_stat_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), member(X, ["STAT 200"])), L1),
    findall(X, (member(X, Transcript), member(X, ["STAT 302", "MATH 302"])), L2),
    length(L1, Length1),
    length(L2, Length2),
    Length1 > 0,
    Length2 > 0,
    append(L1, L2, StatCourses),
    remove_courses(Transcript, StatCourses, ModifiedTranscript, 2).
check_second_year_stat_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), member(X, ["STAT 241", "STAT 251"])), StatCourses),
    length(StatCourses, Length),
    Length > 0,
    remove_courses(Transcript, StatCourses, ModifiedTranscript, 1).


% check_upper_year_core_req(["CPSC 310", "CPSC 313", "CPSC 320", "CPSC 304", "CPSC 312", "CPSC 340", "CPSC 404", "CPSC 410", "CPSC 416"], MT).
check_upper_year_core_req(Transcript, ModifiedTranscript) :-
    check_third_year_cpsc_req(Transcript, MT1),
    check_upper_year_cpsc_req(MT1, ModifiedTranscript),
    write("Upper Year Core Requirement is Satisfied.\n").

% check_third_year_cpsc_req(["CPSC 310", "CPSC 313", "CPSC 320"], MT).
check_third_year_cpsc_req(Transcript, ModifiedTranscript) :-
    findall(X, (member(X, Transcript), third_year_cpsc(X)), L1),
    length(L1, Length1),
    Length1 > 2,
    remove_courses(Transcript, L1, ModifiedTranscript, 3).

third_year_cpsc("CPSC 310").
third_year_cpsc("CPSC 313").
third_year_cpsc("CPSC 320").

% check_upper_year_cpsc_req(["CPSC 304", "CPSC 312", "CPSC 340", "CPSC 404", "CPSC 410", "CPSC 416"], MT).
check_upper_year_cpsc_req(Transcript, ModifiedTranscript) :-
    upper_year_cpsc_helper(Transcript, FourthYearCpscCreditList, FourthYearCpscCourses, 399),
    credit_sum(FourthYearCpscCreditList, Sum),
    Sum > 8,
    remove_courses(Transcript, FourthYearCpscCourses, MT1, 3),
    upper_year_cpsc_helper(MT1, ThirdYearCpscCreditList, ThirdYearCpscCourses, 299),
    credit_sum(ThirdYearCpscCreditList, Sum),
    Sum > 8,
    remove_courses(MT1, ThirdYearCpscCourses, ModifiedTranscript, 3).

% returns list of credits and list of cpsc courses with num > CourseNum
% upper_year_cpsc_helper(["CPSC 304", "CPSC 312", "CPSC 340", "CPSC 404", "CPSC 410", "CPSC 416"], L1, L2, 399).
upper_year_cpsc_helper([],[],[],_).
upper_year_cpsc_helper([H|T], [Credit|T2], [H|L2], CourseNum) :-
    get_course_info(H, SC, SN),
    SC = "CPSC",
    atom_number(SN, Num),
    Num > CourseNum,
    credit(SC, SN, Credit),
    upper_year_cpsc_helper(T, T2, L2, CourseNum).
upper_year_cpsc_helper([_|T], L1, L2, CourseNum) :-
    upper_year_cpsc_helper(T, L1, L2, CourseNum).


% check_arts_req(["MATH 100","CHEM 121","CLST 301", "GERM 433", "LATN 101", "PHIL 120"], MT).
check_arts_req(Transcript, ModifiedTranscript) :-
    arts_helper(Transcript, ArtsCreditList, ArtsCourses),
    credit_sum(ArtsCreditList, Sum),
    Sum > 11,
    remove_courses(Transcript, ArtsCourses, ModifiedTranscript, 4),
    write("Arts Requirement is Satisfied.\n").

% returns list of credits and list of art courses
arts_helper([],[],[]).
arts_helper([H|T], [Credit|T2], [H|L2]) :-
    get_course_info(H, SC, SN),
    atom_string(SCA, SC),
    faculty(SCA, 'Faculty of Arts'),
    credit(SC, SN, Credit),
    arts_helper(T, T2, L2).
arts_helper([_|T], L1, L2) :-
    arts_helper(T, L1, L2).


% check_breadth_req(["MATH 100","CHEM 121","PHYS 101","BIOL 121","STAT 200","ASTR 101"], MT).
check_breadth_req(TR, MT):-
    check_breadth_general(TR, MT1, "CHEM", N1),
    check_breadth_general(MT1, MT2, "PHYS", N2),
    check_breadth_LFSC(MT2, MT3, N3),
    check_breadth_EPSC(MT3, MT4, N4),
    Total1 is N1+N2+N3,
    Total2 is N1+N2+N3+N4,
    Total2 > 2,
    (   Total1 > 2
    ->  MT = MT3
    ;   Total2 > 2
    ->  MT = MT4
    ;   MT = TR 
    ),
    write("Breadth Requirement is Satisfied.\n").
    

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
    get_course_info(H, SC, _),
    dif(SC, Category),
    breadth_helper(T, L, Category).
breadth_helper([H|T],[H|L],Category) :-
    \+invalid_breadth_courses(H),
    get_course_info(H, Category, SN),
    credit(Category, SN, Credit),
    Credit > 2,
    breadth_helper(T, L, Category).

invalid_breadth_courses("MATH 302").
invalid_breadth_courses("CHEM 100").
invalid_breadth_courses("CHEM 300").
invalid_breadth_courses("PHYS 100").
invalid_breadth_courses("BIOL 140").
invalid_breadth_courses("BIOL 300").
invalid_breadth_courses("EOSC 111").
invalid_breadth_courses("GEOB 207").


/* 
check_upper_level_req(["BIOL 323", "BIOL 324", "BIOL 325", "ECON 301", "ECON 302", "ECON 303", "ECON 304", "ECON 305", 
"ECON 306", "BIOL 325", "CPSC 310", "CPSC 313", "CPSC 320", "CPSC 312", "CPSC 311", "CPSC 314"]).
*/
% should be just enough upper level science and non-science credits
check_upper_level_req(Transcript) :-
    get_upper_level_courses(Transcript, UpperCourses),
    upper_level_helper(UpperCourses, UpperLevelCreditList, UpperLevelScienceCreditList),
    credit_sum(UpperLevelCreditList, Sum1),
    credit_sum(UpperLevelScienceCreditList, Sum2),
    Sum1 > 47,
    Sum2 > 29,
    write("Upper-Level Requirement is Satisfied.\n").


get_upper_level_courses(Transcript, Upper) :-
    findall(
        X,
        (member(X,Transcript), get_course_info(X, _, SN), atom_number(SN, Num), Num > 299),
        Upper).

upper_level_helper([], [], []).
upper_level_helper([H|T], [Credit|T2], UpperLevelScienceCreditList) :-
    get_course_info(H, SC, SN),
    atom_number(SN, Num),
    Num > 299,
    atom_string(SCA, SC),    
    \+faculty(SCA, 'Faculty of Science'),
    credit(SC, SN, Credit),
    upper_level_helper(T, T2, UpperLevelScienceCreditList).
upper_level_helper([H|T], [Credit|T2], [Credit|T3]) :-
    get_course_info(H, SC, SN),
    atom_number(SN, Num),
    Num > 299,
    atom_string(SCA, SC),    
    faculty(SCA, 'Faculty of Science'),
    credit(SC, SN, Credit),
    upper_level_helper(T, T2, T3).
