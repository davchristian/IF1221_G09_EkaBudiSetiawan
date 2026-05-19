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
:- dynamic(discardPile/1).
:- dynamic(arahPermainan/1).
:- dynamic(warnaAktif/1).
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

isKartuAngka(kartu(_, Jenis)) :-
    integer(Jenis),
    Jenis >= 0,
    Jenis =< 9.

cariKartuAngka([Kartu|Sisa], Kartu, Sisa) :-
    isKartuAngka(Kartu),
    !.
cariKartuAngka([Kartu|Sisa], KartuAngka, [Kartu|SisaBaru]) :-
    cariKartuAngka(Sisa, KartuAngka, SisaBaru).

initKartu :-
    retractall(playerCard(_, _)),
    retractall(deck(_)),
    retractall(activeCard(_)),
    retractall(giliran(_)),
    retractall(arahPermainan(_)),
    retractall(warnaAktif(_)),
    retractall(discardPile(_)),
    findall(kartu(Warna, Jenis), kartu(Warna, Jenis), SemuaKartu),
    acakList(SemuaKartu, DeckKocok),
    daftarPemain(DaftarPemain),
    bagiKartu(DaftarPemain, DeckKocok, SisaDeck),
    cariKartuAngka(SisaDeck, KartuAwal, SisaDeckAkhir),
    assertz(activeCard(KartuAwal)),
    assertz(discardPile([KartuAwal])),
    assertz(deck(SisaDeckAkhir)),
    DaftarPemain = [PemainPertama | _],
    assertz(giliran(PemainPertama)),
    assertz(arahPermainan(clockwise)),
    KartuAwal = kartu(WarnaAwal, _),
    assertz(warna_aktif(WarnaAwal)),
    format('Kartu awal: ~w~n', [KartuAwal]).

get_random_card(kartu(Warna, Angka)) :-
    findall(kartu(W, A), kartu(W, A), SemuaKartu),
    random_member(kartu(Warna, Angka), SemuaKartu).

kartuAktif :-
    activeCard(CurCard),
    CurCard = kartu(WarnaAktif, AngkaAktif),
    warnaAktif(WarnaAktif),
    format('Kartu aktif : ~w ~w.', [AngkaAktif, WarnaAktif]), nl.

ambilNKartu(0, Deck, [], Deck).
ambilNKartu(N, [Kartu | SisaDeck], [Kartu | SisaKartu], DeckAkhir) :-
    N > 0,
    N1 is N - 1,
    ambilNKartu(N1, SisaDeck, SisaKartu, DeckAkhir).

ambilKartuN(N, Daftar, Elemen) :-
    integer(N),
    N >= 1,
    nth1(N, Daftar, Elemen).

deleteKartu(1, [_|T], T) :- !.
deleteKartu(N, [H|T], [H|TBaru]) :-
    N > 1,
    N1 is N - 1,
    deleteKartu(N1, T, TBaru).

tambahKeDiscardPile(Kartu) :-
    discardPile(Pile),
    retract(discardPile(Pile)),
    assertz(discardPile([Kartu|Pile])).

shuffleDiscardPileToDeck :-
    discardPile([TopCard|SisaPile]),
    deck(DeckSekarang),
    acakList(SisaPile, PileKocok),
    append(DeckSekarang, PileKocok, DeckBaru),
    retract(deck(DeckSekarang)),
    assertz(deck(DeckBaru)),
    retract(discardPile(_)),
    assertz(discardPile([TopCard])),
    length(DeckBaru, Jumlah).

    