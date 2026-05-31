saveGame :-
    \+ gameMulai, !,
    write('Game belum dimulai!'), nl.
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
    % urutan
    daftarPemain(DaftarPemain),
    write(Data, 'urutan_pemain:'),
    writeListFormat(Data, DaftarPemain),
    write(Data, '.'), nl(Data),
    % giliran
    giliran(Pemain),
    write(Data, 'giliran:'),
    writeq(Data, Pemain),
    write(Data, '.'), nl(Data),
    % discard top
    activeCard(KartuTop),
    cardString(KartuTop, StringKartu),
    format(Data, 'discard_top:~w.~n', [StringKartu]),
    % warna aktif
    ( warna_aktif(Warna) -> true
    ; KartuTop = kartu(Warna, _)),
    format(Data, 'warna_aktif:~w.~n', [Warna]),
    % arah game
    arahPermainan(Arah),
    arahGameString(Arah, StringArah),
    format(Data, 'arah_permainan:~w.~n', [StringArah]),
    % uni
    findall(P, status_UNI(P), ListUNI),
    write(Data, 'status_UNI:'),
    writeListFormat(Data, ListUNI),
    write(Data, '.'), nl(Data),
    % kartu player
    saveCard(Data, DaftarPemain).

saveCard(_, []).
saveCard(Data, [H|Sisa]) :-
    playerCard(H, ListKartu),
    listCardString(ListKartu, StringCards),
    write(Data, 'kartu('),
    writeq(Data, H),
    write(Data, '):['),
    write(Data, StringCards),
    write(Data, '].'),
    nl(Data),
    saveCard(Data, Sisa).

cardString(kartu(Warna, Jenis), String) :-
    ( integer(Jenis) -> number_codes(Jenis, Codes),
    atom_codes(JenisAtom, Codes)
    ; JenisAtom = Jenis),
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

writeListFormat(Data, List) :-
    write(Data, '['),
    writeList(Data, List),
    write(Data, ']').

writeList(_, []) :- !.
writeList(Data, [H]) :-
    writeq(Data, H), !.
writeList(Data, [H|T]) :-
    writeq(Data, H),
    write(Data, ','),
    writeList(Data, T).

arahGameString(clockwise, kanan).
arahGameString(counterclockwise, kiri).