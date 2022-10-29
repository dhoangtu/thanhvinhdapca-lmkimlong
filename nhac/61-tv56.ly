% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 56"
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
  \key c \major
  \time 2/4
  \partial 4 \tuplet 3/2 { e8 e f } |
  d4. c8 |
  g'4 \tuplet 3/2 { f8 f g } |
  e4 r8 e16 e |
  a4. b16 a |
  g8 c b c |
  d2 ~ |
  d4 \tuplet 3/2 { e8 e e } |
  c4. d8 |
  b4 \tuplet 3/2 { c8 c c } |
  a4 r8 a16 c |
  g4. g16 a |
  f8 e d g |
  c,2 ~ |
  c4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      \tuplet 3/2 { g8 a g } |
      g4. e8 |
      a4 \tuplet 3/2 { g8 d' c } |
      c2 ~ |
      c4 \bar "|."
    }
    {
      \tuplet 3/2 { e,8 f e } |
      e4. c8 |
      f4 \tuplet 3/2 { e8 f f } |
      e2 ~ |
      e4
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      \tuplet 3/2 { g8 a g } |
      e4. c8 |
      a'4 \tuplet 3/2 { g8 d' c } |
      c2 ~ |
      c4 \bar "|."
    }
    {
      \tuplet 3/2 { e,8 f e } |
      c4. c8 |
      f4 \tuplet 3/2 { e8 f f } |
      a2 ~ |
      a4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin thương xót con, lạy Chúa, xin thương xót con,
      Này hồn con vẫn luôn tìm nương ẩn nơi Chúa,
      Dưới bóng cánh Ngài con hằng nương thân đêm ngày
      cho tới khi qua hết bao tai nạn hãi hùng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Con xin Chúa thương rộng ban trăm muôn phúc lộc,
      Từ trời xanh ước mong bàn tay Ngài giải thoát.
      Quất ngã hết bọn quân thù bao vây con này.
      Xin Chúa ban bao mến thương với lòng tín thành.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Oai phong Chúa thương biểu dương trên muôn cõi trời,
      Nguyện Ngài mau chiếu soi hiển vinh đầy mặt đất.
      Chúa vẫn tính thành trổi vượt trên mây muôn ngàn,
      Luôn mến thương cao lút cả cung trời chín tầng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Con luôn vững tâm, lạy Chúa, con luôn vững tâm,
      Và này con tấu cung đàn xin được ca xướng.
      Thức giấc hỡi hồn, chỗi dậy cung tơ cung cầm,
      tôi sẽ lay cho ánh ban mai cùng chỗi dậy.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Nơi muôn quốc gia, lạy Chúa, con xin cảm tạ,
      Từ ngàn dân, tấu cung đàn dâng lời hoan chúc.
      Chúa vẫn tín thành trổi vượt trên mây muôn ngàn,
      Luôn mến thương cao lút cả cung trời chín tầng.
    }
  >>
}

loiPhanHai = \lyricmode {
  Xin xót thương con, lạy Chúa, nguyện xót thương con.
}

loiPhanBa = \lyricmode {
  Con tán dương Ngài, lạy Chúa, ở giữa muôn dân.
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
        \line { \small "-t5 c /2TN: câu 1, 2, 3, 4 + Đ.1" }
        \line { \small "-t7 c /24TN: câu 3, 4 + Đ.2" }
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
