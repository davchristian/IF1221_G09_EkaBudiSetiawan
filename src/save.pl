saveGame :-
    \+ gameMulai, !, write('Game belum dimulai!'), nl.
saveGame :-
    menunggu_respons_draw_four(_, _), !,
    write('Pilih "tantang." atau "ambilKartu." sebelum save.'), nl.
saveGame :-
    menunggu_respons_draw_two, !,
    write('"ambilKartu." sebelum save.'), nl.
saveGame :-
    write('Masukkan nama file penyimpanan: '),
    read(NamaFile),
    atom_concat(NamaFile, '.txt', NamaFileTxt),
    open(NamaFileTxt, write, Data),
    gameState(Data),
    close(Data),
    format('Status permainan berhasil disimpan ke ~w.~n', [NamaFileTxt]).

gameState(Data) :-
    daftarPemain(DaftarPemain),
    format(Data, 'urutan_pemain(~w).~n', [DaftarPemain]),
    giliran(Pemain),
    format(Data, 'giliran(~w).~n', [Pemain]),
    activeCard(KartuTop),
    cardString(KartuTop, StringKartu),
    format(Data, 'discard_top:~w.~n', [StringKartu]),
    ( warna_aktif(Warna) -> true 
    ; KartuTop = kartu(Warna, _) ),
    format(Data, 'warna_aktif:~w.~n', [Warna]),
    arahPermainan(Arah),
    arahGameString(Arah, StringArah),
    format(Data, 'arah_permainan:~w.~n', [StringArah]),
    findall(P, status_UNI(P), ListUNI),
    format(Data, 'status_UNI(~w).~n', [ListUNI]),
    saveCard(Data, DaftarPemain).

saveCard(_, []).
saveCard(Data, [H|Sisa]) :-
    kartu_pemain(H, ListKartu), 
    listCardString(ListKartu, StringCards),
    format(Data, 'kartu(\'~w\'):[~w].~n', [H, StringCards]),
    saveCard(Data, Sisa).

cardString(kartu(Warna, Jenis), String) :-
    ( integer(Jenis) -> number_atom(Jenis, JenisAtom) 
    ; JenisAtom = Jenis ),
    atom_concat(Warna, '-', Tmp),
    atom_concat(Tmp, JenisAtom, String).

listCardString([], '').
listCardString([K], String) :-
    cardString(K, String), !.
listCardString([K|Sisa], String) :-
    cardString(K, StringK),
    listCardString(Sisa, StringSisa),
    atom_concat(StringK, ',', Tmp),
    atom_concat(Tmp, StringSisa, String).

arahGameString(clockwise, kanan).
arahGameString(counterclockwise, kiri).
