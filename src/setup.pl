:- dynamic(daftarPemain/1).
:- dynamic(giliran/1).
:- dynamic(gameMulai/0).

startGame :-
    gameMulai,
    write('Game sudah dimulai.'), nl, !.

startGame :-
    resetGame,

    mintaJmlhPemain(Jumlah),
    nl,

    ambilSemuaNama(Jumlah, [], DaftarNama),

    UrutanAcak = DaftarNama,

    asserta(daftarPemain(UrutanAcak)),

    UrutanAcak = [PemainPertama | _],
    asserta(giliran(PemainPertama)),

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
    retractall(gameMulai).

tampilUrutan([X]) :-
    write(X).

tampilUrutan([X | Sisa]) :-
    write(X),
    write(' - '),
    tampilUrutan(Sisa).