% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 94"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% mã nguồn cho những chức năng chưa hỗ trợ trong phiên bản lilypond hiện tại
% cung cấp bởi cộng đồng lilypond khi gửi email đến lilypond-user@gnu.org
% in số phiên khúc trên mỗi dòng
#(define (add-grob-definition grob-name grob-entry)
     (set! all-grob-descriptions
           (cons ((@@ (lily) completize-grob-entry)
                  (cons grob-name grob-entry))
                 all-grob-descriptions)))

#(add-grob-definition
    'StanzaNumberSpanner
    `((direction . ,LEFT)
      (font-series . bold)
      (padding . 1.0)
      (side-axis . ,X)
      (stencil . ,ly:text-interface::print)
      (X-offset . ,ly:side-position-interface::x-aligned-side)
      (Y-extent . ,grob::always-Y-extent-from-stencil)
      (meta . ((class . Spanner)
               (interfaces . (font-interface
                              side-position-interface
                              stanza-number-interface
                              text-interface))))))

\layout {
    \context {
      \Global
      \grobdescriptions #all-grob-descriptions
    }
    \context {
      \Score
      \remove Stanza_number_align_engraver
      \consists
        #(lambda (context)
           (let ((texts '())
                 (syllables '()))
             (make-engraver
              (acknowledgers
               ((stanza-number-interface engraver grob source-engraver)
                  (set! texts (cons grob texts)))
               ((lyric-syllable-interface engraver grob source-engraver)
                  (set! syllables (cons grob syllables))))
              ((stop-translation-timestep engraver)
                 (for-each
                  (lambda (text)
                    (for-each
                     (lambda (syllable)
                       (ly:pointer-group-interface::add-grob
                        text
                        'side-support-elements
                        syllable))
                     syllables))
                  texts)
                 (set! syllables '())))))
    }
    \context {
      \Lyrics
      \remove Stanza_number_engraver
      \consists
        #(lambda (context)
           (let ((text #f)
                 (last-stanza #f))
             (make-engraver
              ((process-music engraver)
                 (let ((stanza (ly:context-property context 'stanza #f)))
                   (if (and stanza (not (equal? stanza last-stanza)))
                       (let ((column (ly:context-property context
'currentCommandColumn)))
                         (set! last-stanza stanza)
                         (if text
                             (ly:spanner-set-bound! text RIGHT column))
                         (set! text (ly:engraver-make-grob engraver
'StanzaNumberSpanner '()))
                         (ly:grob-set-property! text 'text stanza)
                         (ly:spanner-set-bound! text LEFT column)))))
              ((finalize engraver)
                 (if text
                     (let ((column (ly:context-property context
'currentCommandColumn)))
                       (ly:spanner-set-bound! text RIGHT column)))))))
      \override StanzaNumberSpanner.horizon-padding = 10000
    }
}

stanzaReminderOff =
  \temporary \override StanzaNumberSpanner.after-line-breaking =
     #(lambda (grob)
        ;; Can be replaced with (not (first-broken-spanner? grob)) in 2.23.
        (if (let ((siblings (ly:spanner-broken-into (ly:grob-original grob))))
              (and (pair? siblings)
                   (not (eq? grob (car siblings)))))
            (ly:grob-suicide! grob)))

stanzaReminderOn = \undo \stanzaReminderOff
% kết thúc mã nguồn

% Nhạc
nhacPhanMot = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8 g16
  <<
    {
      \voiceOne
      g
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1.5
      \parenthesize
      e
    }
  >>
  \oneVoice
  e8. e16 \tuplet 3/2 { e8 e d } |
  b'4. b16 b |
  g8. c16 \tuplet 3/2 { c8 e, g } |
  a4 \tuplet 3/2 { a8 d
    <<
      {
        \voiceOne
        d
      }
      \new Voice = "splitpart" {
        \voiceTwo
        \once \override NoteColumn.force-hshift = #1.5
        \parenthesize
        b
      }
    >>
  }
  \oneVoice
  b8. a16 \tuplet 3/2 { a8 g a } |
  e4. d16 a' |
  a8. a16 \tuplet 3/2 { a8 d fs, } |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 8
  <<
    {d8 |
     g4 c8 b |
     a4. g8 |
     e4 d |
     g4 r8 \bar "|."
    }
    {
      b,8 |
      e4 a8 g |
      fs4. e8 |
      c4 c |
      b r8
    }
  >>
}

nhacPhanBa = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  g4
  <<
    {
      a |
      b4 \tuplet 3/2 { g8 c b } |
      a4 \tuplet 3/2 { fs8 d fs } |
      a (g4) \bar "|."
    }
    {
      fs4 |
      g \tuplet 3/2 { e8 a g } |
      d4 \tuplet 3/2 { d8 c c } |
      c (b4)
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8 g8 |
  g4 \tuplet 3/2 { b8 e, g } |
  <<
    {
      a8. a16 b8 b |
      b4 r8 c |
      a4 d8 d
    }
    {
      fs,8. fs16 g8 g |
      g4 r8 a |
      fs4 fs8 fs
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy đến đây ta reo vui mừng Chúa,
      tung hô Ngài, Núi đá độ trì ta.
      Vào trước Thánh Nhan ta dâng lời cảm tạ,
      cùng tung hô theo muôn tiếng đàn ca.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Đức Chúa đây, Vua cao sang quyền phép,
      chính Chúa Trời, Đấng trổi vượt thần minh.
      Ngài nắm \markup { \underline "trong" } tay bao âm vực địa cầu
      và trông coi muôn sơn lĩnh vời cao.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Hãy cúc cung nơi Tôn Nhan phục bái,
      tiến bước vào kính Đấng tạo thành ta,
      là Đức Chúa ta, ta đây thuộc dân Ngài,
      Ngài canh coi như chăn dắt đàn chiên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy chú tâm hôm nay nghe lời Chúa,
      chớ cứng lòng giống lúc ở Mas -- sa, tại Mê -- ri -- ba,
      xem bao việc Ta làm, tổ thiên xưa manh tâm dám thử ta.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Bốn \markup { \underline "mươi" } năm, dân Ta, Ta đà ngán,
      mới phán rằng: Chúng đã lạc đường đi,
      và lối bước ta, không thông,
      làm ta giận, thề không cho đi vô chốn nghỉ ngơi.
    }
  >>
}

loiPhanHai = \lyricmode {
  Hãy vào trước Thiên Nhan dâng lời cảm tạ.
}

loiPhanBa = \lyricmode {
  Ma -- ra -- na -- tha, Lạy Chúa Giê -- su, xin Ngài ngự đến.
}

loiPhanBon = \lyricmode {
  Hôm nay ước gì anh em nghe tiếng Chúa phán:
  Các ngươi chớ cứng lòng.
}

% Dàn trang
\paper {
  #(set-paper-size "a5")
  top-margin = 3\mm
  bottom-margin = 3\mm
  left-margin = 3\mm
  right-margin = 3\mm
  indent = #0
  #(define fonts
	 (make-pango-font-tree "Deja Vu Serif Condensed"
	 		       "Deja Vu Serif Condensed"
			       "Deja Vu Serif Condensed"
			       (/ 20 20)))
  print-page-number = ##f
  ragged-bottom = ##t
  page-count = 2
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t5 l /1TN: câu 3, 4, 5 + Đ.3" }
        \line { \small "-Cn B /4TN: câu 1, 3, 4 + Đ.3" }
        \line { \small "-Cn C /18TN: câu 1, 3, 4 + Đ.3" }
        \line { \small "-t5 l /18TN: câu 1, 3, 4 + Đ.3" }
        \line { \small "-Cn A /23TN: câu 1, 3, 4 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Cn C /27TN: câu 1, 3, 4 + Đ.3" }
        \line { \small "-t7 c /34TN: câu 1, 2, 3 + Đ.2" }
        \line { \small "-Cn A /3MC: câu 1, 3, 4 + Đ.3" }
        \line { \small "-t5 /3MC: câu 1, 3, 4 + Đ.3" }
        \line { \small "-Cung hiến T. Đường: câu 1, 2, 3 + Đ.1" }
      }
    }
  %}
}

\score {
  <<
    \new Staff <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMot
        }
      \new Lyrics \lyricsto beSop \loiPhanMot
    >>
  >>
  \layout {
    \override Lyrics.LyricSpace.minimum-distance = #1
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.1" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanHai
        }
      \new Lyrics \lyricsto beSop \loiPhanHai
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.2" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBa
        }
      \new Lyrics \lyricsto beSop \loiPhanBa
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.3" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBon
        }
      \new Lyrics \lyricsto beSop \loiPhanBon
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
