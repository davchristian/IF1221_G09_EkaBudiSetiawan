kartu(kuning, 0).
kartu(kuning, 1).
kartu(kuning, 2).
kartu(kuning, 3).
kartu(kuning, 4).
kartu(kuning, 5).
kartu(kuning, 6).
kartu(kuning, 7).
kartu(kuning, 8).
kartu(kuning, 9).

kartu(merah, 0).
kartu(merah, 1).
kartu(merah, 2).
kartu(merah, 3).
kartu(merah, 4).
kartu(merah, 5).
kartu(merah, 6).
kartu(merah, 7).
kartu(merah, 8).
kartu(merah, 9).

kartu(biru, 0).
kartu(biru, 1).
kartu(biru, 2).
kartu(biru, 3).
kartu(biru, 4).
kartu(biru, 5).
kartu(biru, 6).
kartu(biru, 7).
kartu(biru, 8).
kartu(biru, 9).

kartu(hijau, 0).
kartu(hijau, 1).
kartu(hijau, 2).
kartu(hijau, 3).
kartu(hijau, 4).
kartu(hijau, 5).
kartu(hijau, 6).
kartu(hijau, 7).
kartu(hijau, 8).
kartu(hijau, 9).

kartu(kuning, reverse).
kartu(merah, reverse).
kartu(biru, reverse).
kartu(hijau, reverse).

kartu(kuning, skip).
kartu(merah, skip).
kartu(biru, skip).
kartu(hijau, skip).

kartu(kuning, drawTwo).
kartu(merah, drawTwo).
kartu(biru, drawTwo).
kartu(hijau, drawTwo).

kartu(hitam, wild).
kartu(hitam, wild).
kartu(hitam, wild).
kartu(hitam, wild).

kartu(hitam, wildFour).
kartu(hitam, wildFour).
kartu(hitam, wildFour).
kartu(hitam, wildFour).

:- dynamic(activeCard/1).
:- dynamic(deck/1).
:- dynamic(playerCard/2).
:- use_module(library(random)).
:- use_module(library(lists)).

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

ambilAngka([K|S], K, S) :-
    K = kartu(_, J),
    integer(J), !.
ambilAngka([_|S], K, D) :-
    ambilAngka(S, K, D).

bagiKartu([], Deck, Deck).
bagiKartu([Pemain | SisaPemain], DeckAwal, DeckSisa) :-
    ambilNKartu(7, DeckAwal, TanganPemain, DeckSetelahAmbil),
    assertz(playerCard(Pemain, TanganPemain)),
    bagiKartu(SisaPemain, DeckSetelahAmbil, DeckSisa).

initKartu :-
    retractall(playerCard(_, _)),
    retractall(deck(_)),
    retractall(activeCard(_)),
    findall(kartu(Warna, Jenis), kartu(Warna, Jenis), SemuaKartu),
    acakList(SemuaKartu, DeckKocok),
    daftarPemain(DaftarPemain),
    bagiKartu(DaftarPemain, DeckKocok, SisaDeck),
    ambilAngka(SisaDeck, KartuAwal, SisaDeckAkhir),
    assertz(activeCard(KartuAwal)),
    assertz(deck(SisaDeckAkhir)).

ambilNKartu(0, Deck, [], Deck).
ambilNKartu(N, [Kartu | SisaDeck], [Kartu | SisaKartu], DeckAkhir) :-
    N > 0,
    N1 is N - 1,
    ambilNKartu(N1, SisaDeck, SisaKartu, DeckAkhir).

ambilKartuN(N, Daftar, Elemen) :-
    integer(N),
    N >= 1,
    nth1(N, Daftar, Elemen).

deleteKartu(N, Daftar, DaftarBaru) :-
    integer(N),
    N >= 1,
    nth1(N, Daftar, _, DaftarBaru).

mainkanKartu(NomorUrutKartuDiTangan) :-  
    giliran(Pemain),
    playerCard(Pemain, Tangan),
    activeCard(KartuAktif),
    ( ambilKartuN(NomorUrutKartuDiTangan, Tangan, KartuPilihan) ->
        KartuPilihan = kartu(WarnaPilihan, JenisPilihan),
        format('~w memainkan kartu: ~w-~w.~n', [Pemain, WarnaPilihan, JenisPilihan]),
        deleteKartu(NomorUrutKartuDiTangan, Tangan, TanganBaru),
        retract(playerCard(Pemain, Tangan)),
        assertz(playerCard(Pemain, TanganBaru)),
        retract(activeCard(KartuAktif)),
        assertz(activeCard(KartuPilihan)),
        nextPlayer(PemainBerikutnya),
        retract(giliran(Pemain)),
        assertz(giliran(PemainBerikutnya)),
        format('Giliran ~w.~n', [PemainBerikutnya])   
    ; 
      write('Nomor kartu salah.'), nl
    ).

ambilKartu :-
    giliran(Pemain),
    playerCard(Pemain, TanganSekarang),
    deck(DeckSekarang),
    ( DeckSekarang = [KartuBaru|DeckBaru] ->
        KartuBaru = kartu(WarnaBaru, JenisBaru),
        format('~w mendapatkan kartu: ~w-~w.~n', [Pemain, WarnaBaru, JenisBaru]),
        append(TanganSekarang, [KartuBaru], TanganBaru),
        retract(playerCard(Pemain, TanganSekarang)),
        assertz(playerCard(Pemain, TanganBaru)),
        retract(deck(DeckSekarang)),
        assertz(deck(DeckBaru)),
        nextPlayer(PemainBerikutnya),
        retract(giliran(Pemain)),
        assertz(giliran(PemainBerikutnya)),
        format('Giliran ~w.~n', [PemainBerikutnya]),
        write('yes'), nl
    ;
        write('Deck kosong!'), nl
    ).


kartuAktif :-
    activeCard(CurCard),
    CurCard = kartu(WarnaAktif, AngkaAktif),
    format('Kartu aktif : ~w ~w.', [AngkaAktif, WarnaAktif]),nl.


    