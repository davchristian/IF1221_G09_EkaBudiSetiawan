/* lihatCommand */
lihatCommand :-
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    write('2. mainkanKartu(NomorUrut)'), nl,
    write('3. tantang'), nl,
    write('4. uni(NomorUrut)'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.
    write('4. tangkap(NamaPemain)'), nl.

/* lihatKartu */
lihatKartu :-
    \+ gameMulai, !, 
    write('Game belum dimulai. Gunakan "startGame" untuk memulai.'), nl.

lihatKartu :-
    giliran(PemainAktif),
    playerCard(PemainAktif, ListKartu),
    write('Berikut kartu yang anda miliki:'), nl,
    tampilDaftarKartu(ListKartu, 1).

tampilDaftarKartu([], _).
tampilDaftarKartu([H|T], Index) :-
    format('~d. ~w~n', [Index, H]),
    NextIndex is Index + 1,
    tampilDaftarKartu(T, NextIndex).

/* cekInfo */
cekInfo :-
    \+ gameMulai, !,
    write('Game belum dimulai.'), nl.

cekInfo :-
    gameMulai,
    \+ activeCard(_), !,
    write('Kartu belum diinisialisasi. Jalankan startGame ulang.'), nl.

cekInfo :-
    activeCard(Top),
    format('Kartu discard top: ~w.~n~n', [Top]),
    daftarPemain(Urutan),
    write('Urutan pemain: '),
    tampilUrutanInfo(Urutan), nl, nl,
    
    /* Informasi Detail Pemain */
    tampilDetailPemain(Urutan, 1).

tampilUrutanInfo([X]) :- write(X), write('.').
tampilUrutanInfo([X|T]) :- write(X), write(' - '), tampilUrutanInfo(T).

tampilDetailPemain([], _).
tampilDetailPemain([Pemain|T], Index) :-
    playerCard(Pemain, List),
    length(List, Jumlah),
    format('Nama pemain ~d: ~w~n', [Index, Pemain]),
    format('Jumlah kartu : ~d~n~n', [Jumlah]),
    NextIndex is Index + 1,
    tampilDetailPemain(T, NextIndex).