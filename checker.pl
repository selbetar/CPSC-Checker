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
% e.g) remove_courses(["CPSC 410", "ENGL 110"], MT, ["ENGL 110"], 1)
% MT = ["CPSC 410"]
remove_courses(Transcript,ModifiedTranscript, RemoveList, N).
% TODO



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

% TODO
check_breadth_req(Transcript, ModifiedTranscript).

% TODO
% electives requirement
check_elect_req(Transcript).
