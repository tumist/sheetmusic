\version "2.12.2"

\header {
  title = "Jin and Sun"
  subtitle = \markup { "from" \italic "Lost" }
  composer = "Michael Giacchino"
}

global = {
  \tempo 4 = 60
  \key c \major
  \time 4/4
  \numericTimeSignature
  s1*30
  \bar "|."
}

upper = \relative c'' {
  \clef treble
  e2( g4 b
  d2 c)
  d( d4 a
  c2 b)
  \break

  c( c4 fis,
  b1
  <g, g'>4( <a a'> <b b'> <g g'>
  <a a'>2 <b b'>)
  \break

  e( g4 b
  d2 c)
  d( d4 a
  c2 b4 a)
  \break

  a2( a4 fis
  b2 fis4 a)
  <g g'>( <a a'> <b b'> <g g'>
  <a a'> <ges ges'> <b b'>2)
  \break

  R1*2
  <e,, e'>2( <g g'>4 <b b'>
  <d d'>2 <c c'>)
  \break

  <d d'>( <d d'>4 <a a'>
  <c c'>2 <b b'>)
  <a a'>( <a a'>4 <fis fis'>
  \break

  <b b'>1)
  <g g'>4( <a a'> <b b'> <g g'>
  <a a'>2 <b dis fis b>\arpeggio)
  \break

  <g b e g>8 r <g b e g>2.
  <b, e g b>8 r <b e g b>2.
  <e, g b e>1~
  <e g b e>\fermata
}

lower = \relative c' {
  \clef treble
  <a b e>8 r <g b e>2.
  <e a c>8 r <e a c>2.
  <a d fis>8 r <a d fis>2.
  <b d g>8 r <b d g>2.

  <g c e>8 r <g c e>2.
  <fis a b d>2 <fis a b dis>
  <g b> <g c>
  <d fis a> <dis fis a>

  <e g c>1
  <f a c>
  <f a c g'>
  <g b d g>

  <c e g>8 r <c e g>2.
  <b d fis a>8 r <b d fis a>4 <b dis fis a>2
  <b e g>8 r <b e g>4 <c e g>2
  <d fis a>2 <dis fis a>

  <e g b>8 r <e g b>2.
  <b e g>8 r <b e g>2.
  \clef bass
  e,,8 b' fis' b, g' fis e d
  c g' d' g, e'4 c,8 b

  a e' c' e, d fis c' b
  <g, a'> d' g d b'4 g,8 b
  c g' c g e'2

  b,8 fis' b d <fis, a b dis>2\arpeggio
  e,8 b' a' e b' e, g e
  a, e' a c <fis, a b dis>2\arpeggio

  R1*3
  <e,, e'>1\fermata
}

dynamics = {
  s1*14\p
  s32*45\< s32\! s32*2 s32*16\mf
  s1*8\p
  s32*45\< s32\! s32*2 s32*16\f
  s1-\markup { \dynamic "p" "rit." }
}

pedal = {
}

chordnames = \chordmode {
}

\score {
  \new PianoStaff = "PianoStaff_pf" <<
    \set PianoStaff.instrumentName = #"Piano"
    \new ChordNames = "chordnames" \chordnames
    \new Staff = "Staff_pfUpper" << \global \upper >>
    \new Dynamics = "Dynamics_pf" \dynamics
    \new Staff = "Staff_pfLower" << \global \lower >>
    \new Dynamics = "pedal" \pedal
  >>

  \layout {
    % define Dynamics context
    \context {
      \type "Engraver_group"
      \name Dynamics
      \alias Voice
      \consists "Output_property_engraver"
      \consists "Piano_pedal_engraver"
      \consists "Script_engraver"
      \consists "New_dynamic_engraver"
      \consists "Dynamic_align_engraver"
      \consists "Text_engraver"
      \consists "Skip_event_swallow_translator"
      \consists "Axis_group_engraver"

      % keep spanners and text in the middle
      \override DynamicLineSpanner #'Y-offset = #0
      \override TextScript #'Y-offset = #-0.5

      \override TextScript #'font-shape = #'italic
      \override VerticalAxisGroup #'minimum-Y-extent = #'(-1 . 1)
      \override DynamicText #'extra-spacing-width = #'(0 . 0)

      % XXX: this seems to have no effect, so hairpins are still not
      % padded enough in some cases
      \override Hairpin #'bound-padding = #2.0

      % hack to fix incorrect placement of the instrument name when
      % pedaling instructions are present
      % http://lists.gnu.org/archive/html/lilypond-user/2010-07/msg00402.html
      \override VerticalAxisGroup #'meta =
      #(let* ((descr (assoc-get 'VerticalAxisGroup all-grob-descriptions))
              (meta (assoc-get 'meta descr))
              (ifaces (assoc-get 'interfaces meta)))
        ;; Adding piano-pedal-interface to this VerticalAxisGroup
        ;; prevents it being acknowledged by Instrument_name_engraver
        (acons 'interfaces (cons 'piano-pedal-interface ifaces)
                meta))
    }
    % modify PianoStaff context to accept ChordNames and Dynamics context
    \context {
      \PianoStaff
      \accepts ChordNames
      \accepts Dynamics
    }
  }
}

\score {
  \unfoldRepeats {
    \new PianoStaff = "PianoStaff_pf" <<
      \new Staff = "Staff_pfUpper" << \global \upper \dynamics \pedal >>
      \new Staff = "Staff_pfLower" << \global \lower \dynamics \pedal >>
    >>
  }
  \midi {
    % the following is a workaround to prevent multiple voices from being
    % lumped into the same channel, which would inhibit overlapping notes
    \context {
      \Staff \remove "Staff_performer"
    }
    \context {
      \Voice \consists "Staff_performer"
    }
  }
}

