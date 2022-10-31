% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 80"
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
  \key f \major
  \time 2/4
  \partial 8 a16 c, |
  d4. g16 g |
  g4. f16 (g) |
  a4 r8 a |
  \tuplet 3/2 { bf8 g bf } \tuplet 3/2 { c8 c c } |
  f,4 r8 g16 e |
  e4. e16 g |
  g4. a8 |
  d,4 r8 c |
  \tuplet 3/2 { a8 c f } \tuplet 3/2 { e8 g f } |
  f2 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  f8 d c4 |
  <<
    {
      a'4 a8 bf |
      g4 r8 c |
      bf4 g8 c
    }
    {
      f,4 f8 g |
      e4 r8 e |
      g4 e8 e
    }
  >>
  f2 ~ |
  f4 r8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  f8 d c c |
  <<
    {
      a'4. bf8 |
      e, e4 g8 |
      f4 r8 \bar "|."
    }
    {
      f4. d8 |
      c c4 bf8 |
      a4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy hòa nhạc, khua to lên điệu trống,
      mau tấu rền vang tiếng sắt tiếng cầm.
      Thổi tù và mừng trăng lên đúng rằm,
      và mồng một ta mừng lễ hân hoan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Đó là luật Is -- ra -- el phải cứ,
      Thiên Chúa nhà Gia -- cop đã phán truyền.
      Chỉ thị này nhà Giu -- se đã nhận
      khi rời miền Ai -- cập bước ra đi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Có một giọng sao tôi nghe lạ quá:
      Ta cất khỏi vai ngươi những gánh nặng.
      Buổi ngặt nghèo nhìn lên Ta khấn cầu,
      Ta dủ tình thương giải thoát cho ngay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Giữa mịt mù, mây giông, Ta cảnh báo,
      Bên suối Mê -- ri -- ba đã thử lòng,
      Phải gì họ chịu nghe Ta huấn dụ,
      theo lời Ta khuyên nào Is -- ra -- el.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Các thần lạ không đem vô lều trú,
      bao ngẫu thần ngoại bang chớ kính thờ.
      Hãy phụng sự mình Ta đây, Chúa Trời
      đã từ miền Ai -- cập cứu ngươi ra.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Thế mà họ đâu nghe Ta chỉ dẫn,
      dân Is -- ra -- el cứ mãi khước từ.
      Để mặc họ lòng chai như đá rồi,
      nơi nào họ mê hoặc cứ theo đi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Chớ gì họ nghe Ta đây chỉ lối,
      dân Is -- ra -- el biết giữu đúng lời,
      kẻ thù họ này tay Ta tiễu trừ,
      bao bọn hành hung họ kíp tiêu vong.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Chớ gì họ nghe Ta đây chỉ lối,
      dân Is -- ra -- el biết giữ đúng lời.
      Chỉ mình họ được Ta ban lúa mì,
      ban cả tàng ong mật để no say.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Lũ địch thù nay theo Ta nịnh hót,
      Ta khiển phải kinh hãi đến mãn đời.
      Chỉ mình họ được Ta ban lúa mì,
      ban cả tàng ong mật để no say.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chính Ta là Chúa, Thiên Chúa ngươi, hãy nghe Ta phán dạy.
}

loiPhanBa = \lyricmode {
  Hãy reo mừng Thuợgn Đế, Đấng trợ lục chúng ta.
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
        \line { \small "-t5 c /6TN: câu 5, 6, 7 + Đ.1" }
        \line { \small "-Cn B /9TN: câu 1, 2, 3, 4 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 l /17TN: câu 1, 2, 4 + Đ.2" }
        \line { \small "-t2 l /18TN: câu 6, 7, 9 + Đ.2" }
        \line { \small "-t6 /3MC: câu 3, 4, 5, 8 + Đ.1" }
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