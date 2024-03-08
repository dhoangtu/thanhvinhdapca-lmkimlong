% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 113B"
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

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin đừng làm rạng rỡ chúng con, lạy Chúa, xin đừng.
      Nhưng xin cho danh Ngài rạng rỡ,
      vì Ngài thành tín yêu thương.
      Sao chư dân dám hỏi: Thiên Chúa chúng ở đâu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Đây Ngài thực là Chúa chúng con,
      ngự ở trên trời.
      Ưng chi ra tay Ngài hoàn tất.
      Tượng thần bọn chúng hư vô,
      do tay nhân thế nặn đâu có khác vàng chi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Trông tượng của họ có mắt kìa,
      mà thấy chi nào.
      Đôi môi không lay động một tiếng.
      Và này \markup { \underline "có" } mũi như không,
      không khi nào biết ngửi,
      tai nghe thấy gì đâu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Kia tượng của họ có cánh tay,
      sờ mó chi được,
      Đôi chân không đi nổi một bước.
      Bọn họ \markup { \underline "cũng" } giống y thôi:
      ai ra tay đúc tượng, ai cúng vái cậy tin.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Như vậy, này nhà Is -- ra -- el, hãy vững tin Ngài,
      khiên che, tay bang trợ là Chúa.
      Và này, nhà A -- a -- ron, luôn luôn tin kính Ngài
      như thuẫn đỡ mộc che.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Nay nguyện cầu cùng Chúa chí tôn,
      tạo tác đất trời, ban cho anh em được vạn phúc.
      Trời là của Chúa ta luôn,
      nhân gian nay Chúa tặng cho trái đất này đây.
    }
  >>
}

loiPhanHai = \lyricmode {
  Nhà Is -- ra -- el hãy tin cậy Chúa liên.
}

loiPhanBa = \lyricmode {
  Xin đừng làm rạng rỡ chúng con.
  Lạy Chúa, nhưng xin làm rạng rỡ danh Ngài.
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
        \line { \small "-t3 c /14TN: câu 2, 3, 4, 5 + Đ.1" }
        \line { \small "-t2 /5PS: câu 1, 2, 6 + Đ.2" }
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
