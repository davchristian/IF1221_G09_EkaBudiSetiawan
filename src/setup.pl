:- dynamic(daftarPemain/1).
:- dynamic(status_UNI/1).
:- dynamic(giliran/1).
:- dynamic(gameMulai/0).

:- use_module(library(random)).

startGame :-
    gameMulai,
    write('Game sudah dimulai.'), nl, !.

startGame :-
    resetGame,

    mintaJmlhPemain(Jumlah),
    nl,

    ambilSemuaNama(Jumlah, [], DaftarNama),

    acakList(DaftarNama, UrutanAcak),

    asserta(daftarPemain(UrutanAcak)),
    
    UrutanAcak = [PemainPertama | _],
    asserta(giliran(PemainPertama)),
    initKartu,
    asserta(gameMulai),

    nl,
    write('Urutan pemain: '),
    tampilUrutan(UrutanAcak),
    write('.'), nl, nl,

    write('Giliran '),
    write(PemainPertama),
    write('.'), nl.

resetGame :-
    retractall(daftarPemain(_)),
    retractall(giliran(_)),
    retractall(gameMulai),
    retractall(playerCard(_, _)),
    retractall(deck(_)),
    retractall(activeCard(_)),
    retractall(kartu_pemain(_, _)),
    retractall(discard_top(_)),
    retractall(status_UNI(_)),
    retractall(warna_aktif(_)),
    retractall(menunggu_respons_draw_two),
    retractall(menunggu_respons_draw_four(_, _)).

tampilUrutan([]) :- !.
tampilUrutan([X]) :- !, write(X).
tampilUrutan([X | Sisa]) :-
    write(X),
    write(' - '),
    tampilUrutan(Sisa).

% gnu prolog kaga ada random_permutation co adanya di swi prolog, jadi bikin sendiri pake random dan keysrt
acakList(L, R) :-
    pasangKey(L, KL),
    keysort(KL, KLS),
    ambilVal(KLS, R).

pasangKey([], []).
pasangKey([H|T], [K-H|R]) :-
    random(K),
    pasangKey(T, R).

ambilVal([], []).
ambilVal([_-V|T], [V|R]) :-
    ambilVal(T, R).