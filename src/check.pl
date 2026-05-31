/* lihatCommand */
lihatCommand :-
    menunggu_respons_draw_two, !,
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl,
    write('4. kartuAktif'), nl.

lihatCommand :-
    menunggu_respons_draw_four(_, _), !,
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    write('2. tantang'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl,
    write('4. kartuAktif'), nl.

lihatCommand :-
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    write('2. mainkanKartu(NomorUrut)'), nl,
    write('3. tantang'), nl,
    write('4. uni(NomorUrut)'), nl,
    nl,
    write('Aksi pendukung & bonus yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl,
    write('4. tangkap(NamaPemain)'), nl,
    write('5. kartuAktif'), nl,
    write('6. sembunyikanKartu(NomorUrut)'), nl,
    write('7. tampilkanKartu'), nl,
    write('8. godsHand'), nl,
    write('9. saveGame'), nl.

/* lihatKartu */
lihatKartu :-
    \+ gameMulai, !,
    write('Game belum dimulai. Gunakan "startGame" untuk memulai.'), nl.

lihatKartu :-
    giliran(PemainAktif),
    playerCard(PemainAktif, ListKartu),
    length(ListKartu, Len),
    ( kartu_tersembunyi(PemainAktif, H0) -> true ; H0 = [] ),
    normalizeHiddenIdx(H0, Len, Hidden),
    write('Berikut kartu yang anda miliki:'), nl,
    tampilDaftarKartuHidden(ListKartu, Hidden, 1).

tampilDaftarKartuHidden([], _, _).
tampilDaftarKartuHidden([H|T], Hidden, Index) :-
    ( member(Index, Hidden) ->
        format('~d. ~w (disembunyikan)~n', [Index, H])
    ;
        format('~d. ~w~n', [Index, H])
    ),
    NextIndex is Index + 1,
    tampilDaftarKartuHidden(T, Hidden, NextIndex).

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