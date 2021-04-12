:- use_module(library(readutil)).
:- include('checker.pl').


% The Main function that will be called by a user.
% Takes a path to the transcript file.
% e.g) check_degree('test.txt').
check_degree(FilePath) :- 
    get_transcript(FilePath, Transcript),
    check_credit_count(Transcript),
    check_upper_level_req(Transcript),
    check_comm_req(Transcript, MT1), % MT = ModifiedTranscript
    check_core_req(MT1, MT2),
    check_arts_req(MT2, MT3),
    check_breadth_req(MT3, _).
    

get_transcript(File, Transcript) :-
    read_file_to_string(File, FileContent, []),
    split_string(FileContent, "\n","", Transcript1),
    list_butlast(Transcript1, Transcript).


% Credit:
% Taken from: https://stackoverflow.com/questions/16174681/how-to-delete-the-last-element-from-a-list-in-prolog
list_butlast([X|Xs], Ys) :-                 % use auxiliary predicate ...
   list_butlast_prev(Xs, Ys, X).            % ... which lags behind by one item

list_butlast_prev([], [], _).
list_butlast_prev([X1|Xs], [X0|Ys], X0) :-  
   list_butlast_prev(Xs, Ys, X1).           % lag behind by one