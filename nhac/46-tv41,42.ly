% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 41, 42"
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
  \partial 8 g16 g |
  f4. g8 |
  ef4. c8 |
  c ef4 c8 |
  d4 r8 d |
  g4. bf16 a |
  a4. a16 a |
  a8. a16 \tuplet 3/2 { c8 d bf } |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8 g16 d |
  g4.
  <<
    {
      a8 |
      bf4 \tuplet 3/2 { c8 d fs, } |
      g2 ~ |
      g4 r8 \bar "|."
    }
    {
      fs8 |
      g4 \tuplet 3/2 { ef8 d d } |
      bf2 ~ |
      bf4 r8
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8 g8 |
  f4. g16 d |
  <<
    {
      bf'8. a16 \tuplet 3/2 { c8 d d }
    }
    {
      g,8. d16 \tuplet 3/2 { a'8 g fs }
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8 d16 g, |
  <<
    {
      a4. a8 |
      bf4 \tuplet 3/2 { bf8 a g } |
      fs4 r8
    }
    {
      fs4. d8 |
      g4 \tuplet 3/2 { g8 f ef } |
      d4 r8
    }
  >>
  <<
    {
      \voiceOne
      g16 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c,8
    }
  >>
  \oneVoice
  <<
    {
      d4. bf'16 g |
      a8. a16 \tuplet 3/2 { c8 d c }
    }
    {
      bf,4. d16 ef |
      d8. d16 \tuplet 3/2 { a'8 fs fs }
    }
  >>
  g4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Như nai rừng mong mỏi tìm về suối nước trong,
      Hồn con cũng trông mong được gần Ngài, lạy Thiên Chúa con thờ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Những khát khao Chúa Trời, thật là Chúa vĩnh sinh,
      Hồn con tới khi nao được tìm về, được ra trước nhan Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Nhớ những khi trẩy hội về đền thánh Chúa xưa,
      Hòa muôn tiếng reo vui, từng đoàn người cùng nao nức tưng bừng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa đoái thương xét xử biện hộ chống đỡ con,
      khỏi bao lũ điêu ngoa, khỏi bọn người thực hung ác gian tà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Con nương tựa ở Ngài, Ngài đừng nỡ đuổi con,
      để con bước lang thang, bị địch thù bủa vây áp đảo hoài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa đoái thương phái gửi sự thật với ánh quang,
      Hầu soi dẫn con đi về đền thờ và lên núi thánh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Tiến bước lên tế đàn, được gần Chúa xiết vui,
      Đàn lên, xướng ca lên cảm tạ Ngài là Thiên Chúa con thờ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Bối rối chi, hỡi hồn, phận mình chớ xót xa,
      Cậy trông Chúa luôn đi, tụng mừng Ngài là Thiên Chúa cứu độ.
    }
  >>
}

loiPhanHai = \lyricmode {
  Linh hồn con khao khát Thiên Chúa trường sinh.
}

loiPhanBa = \lyricmode {
  Bao giờ con được đến, được ra mắt Chúa Trời.
}

loiPhanBon = \lyricmode {
  Hãy cậy trông Thiên Chúa, Đấng tôi ca ngợi,
  Bởi Ngài cứu độ tôi, là Thiên Chúa tôi thờ.
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
        \line { \small "-t6 l /25TN: câu 4, 5, 6, 7 + Đ.3" }
        \line { \small "-t7 c /30TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-Vọng PS (b.7): câu 2, 3, 6, 7 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t2 /3MC: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-t2 /4PS: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-Rửa tội: câu 1, 2, 6, 7 + Đ.1" }
        \line { \small "-Cầu hồn: câu 1, 2, 3, 6, 7, 8 + Đ.1 hoặc Đ.2" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
