% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 112"
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
  \key bf \major
  \time 2/4
  \partial 8 g8 |
  d8 d16 d bf'8 bf |
  a2 ~ |
  a8 f a g |
  d4 r8 bf' |
  bf bf16 bf a8 a |
  d4 r8 d, |
  d8.
  <<
    {
      \voiceOne
      d16
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #2.5
      \tweak font-size #-2
      \parenthesize
      bf'16
    }
  >>
  \oneVoice
  bf8 a |
  a4 r8 g16 g |
  g8 a16 (g) ef8 (d) |
  a'8. bf16 bf (a) f8 |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key bf \major
  \time 2/4
  \partial 8
  d8
  <<
    {
      bf'4 a8 (g) |
      a4. a8 |
      f d
    }
    {
      g4 f8 (ef) |
      d4. d8 |
      d bf
    }
  >>
  <<
    {
      \voiceOne
      a'8 _(bf)
    }

    \new Voice = "splitpart" {
      \voiceTwo
      c,4
    }
  >>
  \oneVoice
  <g' bf,>4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8
  g8 |
  d d16 d bf'8 bf |
  <a fs>4 r8 g
  <<
    {
      d'4. c16 bf |
      a8 a c bf
    }
    {
      bf4. a16 g |
      fs8 fs fs fs
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8
  g8 |
  d d16 d bf'8 bf |
  <a fs>4 r8 g
  <<
    {
      d'4. c16 bf |
      a8 a c bf
    }
    {
      bf4. a16 g |
      fs8 fs fs fs
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8
  g8 |
  d d16 d bf'8 bf |
  <a fs>4 r8 g
  <<
    {
      d'4. c16 bf |
      a8 a c bf
    }
    {
      bf4. a16 g |
      fs8 fs fs fs
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
      Này tôi tớ Chúa hãy dâng lời ngợi ca,
      Dâng lời ngợi ca thánh danh Ngài.
      Hãy ca tụng danh thánh Chúa
      từ giờ đây và tới muôn muôn đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Từ rạng đông tới mãi khi trời hoàng hôn,
      ca ngợi lừng vang thánh danh Ngài.
      Chúa siêu việt trên các nước
      và hiển vinh vượt lút cả cung trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Này đây Thiên Chúa trổi cao vượt mọi dân,
      vinh hiển Ngài dâng lút cung trời.
      Chốn cao vời \markup { \underline "Ngài" } cúi xuống
      để nhìn xem địa giới với cung trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Nào ai đâu sánh với Chúa Trời của ta,
      Vua hiển trị trên chốn cao vời,
      Chốn cao vời \markup { \italic \underline "Ngài" } cúi xuống
      để nhìn xem địa giới với cung trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Nào ai đâu sánh với Chúa Trời của ta.
      Đây Ngài nhìn xem đất với trời.
      Kẻ đơn hèn \markup { \underline "Ngài" } cất nhắc
      cùng bần nhân khỏi đất đen phân bợn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Từ nơi bụi cát Chúa nâng người hèn đơn,
      lôi người nghèo lên khỏi phân bợn,
      để ngang hàng dân phú quý,
      đặt ngồi chung hàng phú quý dân Ngài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Vinh quang Chúa vượt lút cõi trời cao.
}

loiPhanBa = \lyricmode {
  Hãy ca ngợi danh thánh Chúa từ giờ đây và đến muôn muôn đời.
}

loiPhanBon = \lyricmode {
  Hãy dâng lời ngợi khen Chúa, Ngài cất nhắc kẻ nghèo túng lên.
}

loiPhanNam = \lyricmode {
  Chúa đặt ngồi chung với hàng quyền quý vinh sang.
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
        \line { \small "-t4 c /19TN: câu 1, 2, 4 + Đ.1" }
        \line { \small "-t7 l /23TN: câu 1, 2, 5 + Đ.2" }
        \line { \small "-CN c /25TN: câu 1, 3, 6 + Đ.3" }
        \line { \small "-t2 c /28TN: câu 1, 2, 5 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-lễ chung Đức Mẹ: câu 1, 2, 4, 6 + Đ.2" }
        \line { \small "-lễ tạ ơn: câu 1, 2, 4, 6 + Đ.2" }
        \line { \small "-lễ Danh Chúa: câu 1, 2, 4 + Đ.2" }
        \line { \small "-T.Matthia: câu 1, 2, 4, 6 + Đ.4" }
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
    \override Lyrics.LyricSpace.minimum-distance = #3
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #3
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #3
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.4" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanNam
        }
      \new Lyrics \lyricsto beSop \loiPhanNam
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #3
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
    ragged-last = ##f
  }
}
