% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 61"
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
nhacPhanMot = \relative c' {
  \key f \major
  \time 2/4
  d8 (f) g g |
  a4. g8 |
  c a16 (g) d8 f |
  g2 |
  r8 g c d16 (c) |
  a8. g16 a8 c |
  d2 |
  b!8. g16 b8 c |
  c4. f,8 |
  g a d, (f) |
  g4. g16 g |
  d'8 bf a8. g16 |
  f8 e g bf |
  d,2 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  d8 (f)
  <<
    {
      g g |
      a4. a8 |
      bf e, g e
    }
    {
      e8 e |
      f4. f8 |
      d d cs cs
    }
  >>
  d2 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a8 (bf) g g |
      a8. g16 f8 a |
      e4
    }
    {
      f8 (g) e e |
      f8. e16 d8 d |
      cs4
    }
  >>
  <<
    {
      \voiceOne
       e8 f16 (e)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      cs8 cs
    }
  >>
  \oneVoice
  d2 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a8 a g f |
      bf4. e,8 |
      f e g (a)
    }
    {
      f8 f e ef |
      d4. c8 |
      d c bf (a)
    }
  >>
  d2 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Chỉ trong Thiên Chúa, tôi mới yên hàn nghỉ ngơi,
      Vì ơn cứu độ bởi Ngài mà tới.
      Duy Ngài là núi đá, là ơn cứu độ tôi,
      là thành lũy chở che, tôi chẳng còn nao núng gì.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Chỉ trong Thiên Cháu, tôi mới yên hàn nghỉ ngơi.
      Điều tôi ước mong bởi Ngài mà tới.
      Duy Ngài là núi đá, là ơn cứu độ tôi,
      là thành lũy chở che, tôi chẳng còn nao núng gì.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Ẩn thân nơi Chúa như núi vững vàng chở che,
      được ơn cứu độ và được vinh sngs.
      Tin cậy avof Chúa mãi,
      nào dân nước của ta,
      và cùng đến thổ lộ tâm tình ở nhan thánh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Này dân ta hỡi, mau vững tin và cậy trông,
      cậy tin suốt đời ở một Thiên Chúa.
      Mau thổ lộ với Chúa mọi tâm ý của ta,
      Vì thực chốn để ta nương ẩn là nơi Chúa Trời.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chỉ trong Thiên Chúa, tôi mới nghỉ ngơi yên hàn.
}

loiPhanBa = \lyricmode {
  Chính nơi Thiên Chúa, tôi được cứu độ và vinh dự.
}

loiPhanBon = \lyricmode {
  Chúa sẽ theo tội phúc mà thưởng phạt mỗi người.
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
  page-count = 1
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
      }
    }
    \column {
      \left-align {
        \line { \small "-Cn A /8TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t2 l /23TN: câu 2, 4 + Đ.2" }
        \line { \small "-t4 l /28TN: câu 1, 2, 4 + Đ.3" }
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
