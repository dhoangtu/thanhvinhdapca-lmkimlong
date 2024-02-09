% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 111"
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
  \partial 8 c8 |
  d,4 \tuplet 3/2 { c8 e d } |
  g4 \tuplet 3/2 { e8 e g } |
  a8. f16 \tuplet 3/2 { d8 d g } |
  c,4 r8 e16 f |
  d8. d16 \tuplet 3/2 { d8 g a } |
  a4 r8 a16 b |
  g8. g16 \tuplet 3/2 { d'8 d b } |
  c4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  c8 |
  g4 \tuplet 3/2 { e8 a g } |
  c2 ~ |
  c4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  c8 |
  g4 \tuplet 3/2 { e8 f g } |
  a8. d,16 \tuplet 3/2 { d8 f e } |
  c2 ~ | c4 r8 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8 c8 |
  g4 \tuplet 3/2 { d8 g f } |
  e4 \tuplet 3/2 { b8 d d } |
  c2 ~ |
  c4 r8 \bar "|."
}

nhacPhanNam = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e16 e |
  f8. d16 \tuplet 3/2 { d8 g a } |
  a8. a16 \tuplet 3/2 { d,8 f e } |
  c2 ~ |
  c4 r8 \bar "|."
}

nhacPhanSau = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e16 g |
  a8. a16 \tuplet 3/2 { d,8 a' g } |
  c2 ~ |
  c4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Phúc thay ngườ tôn sợ Chúa,
      đặt niềm vui sướng nơi mệnh lệnh Chúa truyền.
      Con cháu họ hùng cường trong đất nước,
      bao kẻ lành được chúc phúc bền lâu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Gia đình lộc phúc giầu sang,
      và sự công chính của họ hằng vững bền.
      Kẻ ngay lành rạng ngời trong bóng tối,
      họ công bình và ái tuất từ bi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Ánh quang dọi kẻ lòng ngay,
      là người công chính, nhân hậu và chí từ.
      Vinh phúc người rộng lòng thương giúp đỡ,
      theo giới luật mà sắp xếp việc riêng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Tháng năm họ không chuyển lay.
      Ngàn đời nhân thế vẫn còn tưởng nhớ họ.
      Đâu có sợ phải nhận tin ác dữ,
      luôn vững lòng mà phó thác cậy tin.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Đâu sợ nhận tin dđộc dữ,
      Lòng hằng thư thái tin cậy vào Chúa Trời.
      Luôn vững lòng, chẳng một khi khiêếp hãi.
      Kiêu hãnh nhìn bọn ác đức hổ ngươi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Vững tâm, chẳng chi sợ hãi,
      Họ hằng rộng rãi hỗ trợ kẻ túng nghèo.
      Công chính họ ngàn đơờ kiên vững mãi,
      Uy thế họ rực rỡ trởi vượt lên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Những luôn rộng tay làm phúc,
      người nghèo, kẻ túng luôn được họ hỗ trợ.
      Công chính họ ngàn đời kiên vững mãi,
      Uy thế họ rực rỡ trổi vượt lên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Phúc thay người biết thương xót
      và hằng đoan chính lo liệu việc của mình.
      Chẳng bao giờ họ nhụt tâm, thối chí.
      Bao thế hệ còn nhắc nhớ hiền nhân.
    }
  >>
}

loiPhanHai = \lyricmode {
  Phúc thay người tôn sợ Chúa.
}

loiPhanBa = \lyricmode {
  Phúc thay người luôn ưa thích mệnh lệnh Chúa ban truyền.
}

loiPhanBon = \lyricmode {
  Phúc thay người biết cảm thông và cho vay mượn.
}

loiPhanNam = \lyricmode {
  Trong u tối người bừng lên ánh sáng chiếu dọi kẻ ngay lành.
}

loiPhanSau = \lyricmode {
  Người công chính vững lòng trông cậy Chúa.
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
        \line { \small "-CN A /5TN: câu 3, 4, 6 + Đ.4" }
        \line { \small "-t6 c /6TN: câu 1, 2, 6 + Đ.2" }
        \line { \small "-t2 l /9TN: câu 1, 2, 8 + Đ.1" }
        \line { \small "-t3 l /9TN: câu 1, 5, 7 + Đ.5" }
        \line { \small "-t4 l /1TN: câu 1, 2, 7 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t4 l /31TN: câu 1, 3, 7 + Đ.3" }
        \line { \small "-t7 c /31TN: câu 1, 8, 6 + Đ.1" }
        \line { \small "-t7 c /32TN: câu 1, 2, 8 + Đ.2" }
        \line { \small "-T.Nam/Nữ: câu 1, 2, 5, 7 + Đ.5" }
        \line { \small "-Hôn phối: câu 1, 2, 5, 7 + Đ.2" }
        \line { \small "-T.Laurensô: câu 1, 5, 7 + Đ.3" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.75
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
    \override Lyrics.LyricSpace.minimum-distance = #0.75
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
    \override Lyrics.LyricSpace.minimum-distance = #0.75
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
      instrumentName = \markup { \bold "Đ.5" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanSau
        }
      \new Lyrics \lyricsto beSop \loiPhanSau
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
