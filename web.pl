:- use_module(library(http/http_open)).
:- use_module(library(xpath)).
:- use_module(library(sgml)).
:- use_module(library(uri)).



open_http(URL, DOM) :-
    http_open(URL, In, []),
    call_cleanup(
        load_html(In, DOM, []),
        close(In)).


% faculty is True if SubjectCode is offered by Faculty
% e.g)
%  faculty('CPSC', 'Faculty of Science'). -> True
%  faculty('CPSC', F).
%  F = 'Faculty of Science'
faculty(SubjectCode, Faculty) :-
    open_http("https://courses.students.ubc.ca/cs/courseschedule?pname=subjarea&tname=subj-all-departments", DOM),
    xpath(DOM, //tr, TR),
    xpath(TR, td(1), C1),
    xpath(C1, /self(normalize_space), SubjectCode),
    xpath(TR, td(3), C2),
    xpath(C2, /self(normalize_space), Faculty).


% Credit is a num
% provides the number of credits that a course provide.
% e.g)
% credit("CPSC", "110", Credit)
% Credit = 4
credit(SubjectCode, SubjectNum, Credit) :-
    atom_concat("https://courses.students.ubc.ca/cs/courseschedule?tname=subj-course&course=", SubjectNum, TEMP1),
    atom_concat("&sessyr=2020&sesscd=W&dept=", SubjectCode, TEMP2),
    atom_concat(TEMP2, "&pname=subjarea", TEMP3),
    atom_concat(TEMP1, TEMP3, URL),
    open_http(URL, DOM),
    xpath(DOM, //p, P),
    xpath(P, /self(normalize_space), CreditElem),
    sub_string(CreditElem, _, _, _, 'Credits: '),
    split_string(CreditElem, " ", "" , Tokens),
    nth0(1, Tokens, CreditStr), % get the element at index 1
    atom_number(CreditStr, Credit). % convert str to num
    
