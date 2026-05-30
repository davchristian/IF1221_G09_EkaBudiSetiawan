loadGame :-
    write('Masukkan nama file yang akan dimuat: '),
    read(NamaFile),
    atom_concat(NamaFile, '.txt', NamaFileTxt),
    ( file_exists(NamaFileTxt) -> open(NamaFileTxt, read, Data),
    readData(Data, Line),
    close(Data),
    resetGame,
    readLine(Line),
    assertz(gameMulai),
    (giliran(Player) -> true 
    ; Player = 'belum ada'),
    format('Status Permainan berhasil dimuat dari ~w.~n', [NamaFileTxt]),
    format('Melanjutkan giliran ~w.~n', [Player])
    ; format('File ~w tidak ada.~n', [NamaFileTxt])).

readData(Data, List) :-
    read(Data, Term),
    ( Term == end_of_file -> List = []
    ; List = [Term|Rest],
    readData(Data, Rest)).

readData(Data, [H|T]) :-
    read(Data, H),
    readData(Data, T).

readLine([]).
readLine([H|T]) :-
     % write('data:'), write(H), nl, 
    readDataLine(H),
    readLine(T).

% urutan
readDataLine(urutan_pemain:DaftarPemain) :-
    assertz(daftarPemain(DaftarPemain)), !.
% giliran
readDataLine(giliran:Pemain) :-
    assertz(giliran(Pemain)), !.
% discard top
readDataLine(discard_top:StringKartu) :-
    readCardString(StringKartu, Kartu),
    assertz(activeCard(Kartu)),
    assertz(discardPile([Kartu])), !.
% warna aktif
readDataLine(warna_aktif:Warna) :-
    assertz(warna_aktif(Warna)), !.
% arah game
readDataLine(arah_permainan:StringArah) :-
    arahGameString(Arah, StringArah),
    assertz(arahPermainan(Arah)), !.
% uni
readDataLine(status_UNI:ListUNI) :-
    assertzUni(ListUNI), !.
% kartu player
readDataLine(kartu(Pemain):ListStringKartu) :-
    readlistCardString(ListStringKartu, ListKartu),
    assertz(playerCard(Pemain, ListKartu)), !.

readCardString(Warna-JenisAtom, kartu(Warna, Jenis)) :-
    !,
    ( catch(number_atom(Jenis, JenisAtom), _, fail) -> true 
    ; Jenis = JenisAtom ).
readCardString(Warna, kartu(Warna, none)).

readlistCardString([], []).
readlistCardString([H|T], [Kartu|Sisa]) :-
    readCardString(H, Kartu),
    readlistCardString(T, Sisa).

assertzUni([]).
assertzUni([H|T]) :-
    assertz(status_UNI(H)),
    assertzUni(T).
