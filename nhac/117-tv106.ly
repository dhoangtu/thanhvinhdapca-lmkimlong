% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 106"
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
  \partial 8 a16 a |
  g4. g8 |
  d d16 g f8 e |
  a4 r8 g16 g |
  c8 f, g f |
  e4 r8 e |
  d4. d16 d |
  d8 d4 f16 (g) |
  a4. a,16
  <<
    {
      \voiceOne
      e'
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \stemUp
      \once \override NoteColumn.force-hshift = #2
      \tweak font-size #-2
      \parenthesize
      a,
    }
  >>
  \oneVoice \stemNeutral
  e'8 e a c, |
  d4 r \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  d,4 e |
  f8. d16 g (a) g8 |
  e4 r8 a, |
  a e'16 e c8 c |
  d2 ~ |
  d4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy xướng lên, bao người được Chúa thương giải thoát,
      được giải thoát khỏi tay quân thù,
      bao người được triệu tập từ viễn xứ,
      từ đông tây nam bắc về đây.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hỡi những ai phiêu bạt vùng cát hoang cằn cỗi,
      chẳng còn thấy đường ra thị thành,
      khi họ tưởng là mình đà tận số,
      họng khô ran, bụng đói lả luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chính lúc lâm cơ cùng, họ nhớ kêu cầu Chúa,
      Ngài giựt thoát khỏi cơn hiểm nghèo,
      Đưa họ hành trình thẳng đường ngay lối,
      chọn nơi đâu xung túc định cư.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Cất tiếng lên đa tạ tình mến thương của Chúa,
      vì việc Chúa làm cho nhân trần,
      cho người bụng cồn cào được no cứng,
      họng khô ran nay uống thỏa thuê.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Hết những ai xuôi ngược vượt biển buôn cùng bán,
      vượt triều sóng lèo lái con tàu,
      bao lần nhìn tận tường việc của Chúa,
      là bao uy công giữa biển khơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Chính Chúa đây ra lệnh bùng lên bao triều sóng,
      từng triều sóng xô lấp dập dồn,
      tung họ tận trời rồi dìm vực thẳm.
      Họ lâm nguy như sắp mạng vong.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Chính lúc lâm cơ cùng họ nhớ kêu cầu Chúa,
      Ngài giựt thoát khỏi cơn hiểm nghèo.
      Tay Ngài truyền dừng lại trận bão táp,
      truyền cho bao con sóng lặng im.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Sóng nước nay im lặng, họ sướng vui mừng rỡ,
      và Ngài dẫn về bến trông chờ.
      Nay họ hiệp lời cảm tạ Thiên Chúa
      vì \markup { \underline "tình" } thương, vì những kỳ công.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Chúa hiến sông khô cạn thành sa mạc cằn cỗi,
      đổ mạch suối thành nơi hoang địa,
      đất màu rầy thành ruộng đồng khô chát,
      vì dân cu gian ác tà tâm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa khiến cho sa mạc thành ao hồ đầy nước,
      vùng cằn cỗi thành suối trong lành.
      Quy tụ kẻ nghèo hèn vào ở đó,
      dựng xây bao khu phố định cư.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Chúa đỡ nâng dân nghèo vượt qua cảnh cùng khốn,
      và dòng giống họ tăng như cừu.
      Trông vậy là người lành thực vui sướng.
      Bọn gian đâu dám hở môi.
    }
  >>
}

loiPhanHai = \lyricmode {
  Hãy tạ ơn Chúa vì Chúa nhân từ,
  ngàn đời Chúa vẫn trọn tình thương.
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
        \line { \small "-CN B /12TN: câu 5, 6, 7, 8 + Đáp" }
        \line { \small "-t6 c /20TN: câu 1, 2, 3, 4 + Đáp" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-cầu cho người di cư: 9, 10, 11 + Đáp" }
        \line { \small "-thời kỳ đói kém: câu 1, 2, 3, 4 + Đáp" }
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
      instrumentName = \markup { \bold "Đáp" }} <<
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
