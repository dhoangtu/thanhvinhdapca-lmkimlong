% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 47"
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
  \key c \major
  \time 2/4
  \partial 8 g8 |
  c, c e4 ~ |
  e8 d f e |
  d g a4 |
  a8
  <<
    {
      \voiceOne
      f8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-1
      \parenthesize
      g8
    }
  >>
  \oneVoice
  g8 (f) |
  e4 r8 a16 a |
  g8 g e'16 (f) e8 |
  d4. a16 a |
  b8 c a d |
  g,2 ~ |
  g4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      g4 |
      a4. a8 |
      d, d f f |
      g4
    }
    {
      e4 |
      f4. c8 |
      b b a d |
      e4
    }
  >>
  <<
    {
      \voiceOne
      e16 (g) e (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c8 c
    }
  >>
  \oneVoice
  c4 \bar "|."
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 c4 |
  g'4. e8 |
  d f f8. f16 |
  e8 c
  <<
    {
      \voiceOne
      a'4 ~ |
      a8 g
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-1
      a8 (g |
      f) e
    }
  >>
  \oneVoice
  <<
    {
      a8 (b) |
      c2 ~ |
      c4 r8 \bar "|."
    }
    {
      d, (g) |
      e2 ~ |
      e4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Chúa trọng đại quá, thực đáng muôn lời cung chúc giữa thành đô Ngài.
      Núi thánh Ngài hùng vĩ nguy nga, là niềm vui khắp cả thế trần.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Mãi tận cực bắc là thánh đo của Thiên Đế,
      núi \markup { \underline "Si" } -- on này.
      Giữa các đền đài của Si -- on,
      Ngài tỏ ra chính là lũy thành.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Đã từng hiệp sức kìa biết bao là vua chúa,
      tiến \markup { \underline "quân" } liên hồi,
      Mới thấy thành là khiếp kinh ngay,
      chạy thục thân bởi thật hãi hùng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúng nào chạy thoát, vật vã đau tựa phụ nữ đến ngày lâm bồn,
      Giống những tàu thuyền lúc ra khơi bị cuồng phong cuốn dập lấp vùi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Giữa lòng đền thánh, tưởng nhớ lại tình thương Chúa,
      Đấng \markup { \underline "ta" } tôn thờ,
      uy danh Ngài truyền bá nơi nơi,
      lời ngợi ca lẫy lừng đất trời.
    }
  >>
}

loiPhanHai = \lyricmode {
  Thiên Chúa giữ gìn thành đô kiên vững đến muôn đời.
}

loiPhanBa = \lyricmode {
  Lạy Chúa trong đền thánh Chúa chúng con tưởng nhớ tình thương Chúa.
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
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t5 l /4TN: câu 1, 2, 5, 6 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 c /12TN: câu 1, 2, 5, 6 + Đ.1" }
        \line { \small "-t3 c /15TN: câu 1, 2, 3, 4 + Đ.1" }
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
