% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 32"
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
  \partial 4 c8 d |
  e f16 e d8 e16 (g) |
  a4 f8 e16 (f) |
  e8. e16 \grace {a16 (} c8) d,16 (f) |
  g4 g8 bf |
  c8. a16
  \once \phrasingSlurDashed a \(g\) c8 |
  f,4 e8 g |
  d d16 d g8 b, |
  c4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4 c4 |
  a4.
  <<
    {
      \voiceOne
      a16 (c)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      f,8
    }
  >>
  \oneVoice
  <<
    {
      g4. a8 |
      d, d
    }
    {
      e4. c8 |
      b b
    }
  >>
  <<
    {
      \voiceOne
      d8 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b,4
    }
  >>
  \oneVoice
  c4 \bar "|."
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 c8 d |
  e4
  <<
    {
      d8 e |
      d4. g8 |
      a2 |
      c8 c c a |
      g4
    }
    {
      d8 c |
      b4. c8 |
      f2 |
      a8 a a f |
      e4
    }
  >>
  <<
    {
      \voiceOne
      e16 (d) g8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c,8 c
    }
  >>
  \oneVoice
  c4 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4 r8
  <<
    {
      g8 |
      e (g) a4 ~ |
      a8 f f g |
      d4.
    }
    {
      e8 |
      c (e) f4 ~ |
      f8 d d c |
      b4.
    }
  >>
  <<
    {
      \voiceOne
      e16 (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b8
    }
  >>
  \oneVoice
  c4 \bar "|."
}

nhacPhanNam = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 c8 (d) |
  e4. e8 |
  <<
    {
      f8 d e g |
      a4 a8 c |
      g4 g8 a |
      f4. d8 |
      f g
    }
    {
      d8 b c e |
      f4 f8 a |
      e4 e8 f |
      d4. c8 |
      b b
    }
  >>
  <<
    {
      \voiceOne
      e8 (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b4
    }
  >>
  \oneVoice
  c2 ~ |
  c4 \bar "|."
}

nhacPhanSau = \relative c' {
  \key c \major
  \time 2/4
  <<
    {
      \partial 4 e8 g |
      a4. d,8 |
      d g
    }
    {
      c,8 e |
      f4. a,8 |
      b b
    }
  >>
  <<
    {
      \voiceOne
      e8 (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b4
    }
  >>
  \oneVoice
  c2 ~ |
  c4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Người công chính hãy reo hò mừng Chúa,
      kẻ ngay lành hợp tiếng ngợi khen.
      Tạ ơn Chúa gieo muôn _ tiếng đàn,
      ngợi khen Ngài gảy đàn sắt, đàn tơ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Người công chính hãy reo hò mừng Chúa,
      kẻ ngay lành hợp tiếng ngợi khen.
      Thật vinh phúc dân tin _ kính Ngài,
      và nước là sản nghiệp Chúa chọn riêng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Ngợi khen Chúa với muôn điệu đàn sắt,
      Tạ ơn Ngài nào tấu nhạc lên,
      Bài ca mới dâng lên _ kính Ngài,
      nhạc vang lừng hòa cùng tiếng hò reo.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Lời Thiên Chúa rất ngay thực chân chính,
      việc tay Ngài thực đáng cậy tin,
      Ngài yêu thích công minh _ chính trực,
      tình thương ngài tràn ngập khắp mọi nơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Lời Thiên Chúa khiến cung trời hiện hữu,
      làn hơi Ngài tạo tác ngàn sao.
      Và đại dương thu gom _ nhất lại,
      cùng thủy triều Ngài dồn trữ vào kho.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Lời Thiên Chúa khiến cung trời hiện hữu,
      làn hơi Ngài tạo tác ngàn sao,
      Ngài tuyên phán khai sinh _ các loài,
      Ngài ra lệnh vạn vật xuất hiện ngay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Toàn cõi đất hãy tôn phục Thiên Chúa,
      và muôn người sợ hãi quyền uy.
      Ngài tuyên phán khai sinh _ các loài,
      Ngài ra lệnh vạn vật xuất hiện ngay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Ngài thay đổi các chương trình vạn quốc,
      dẹp tan mọi dự tính ngàn dân.
      Định cương Chúa muôn năm _ vững bền,
      và kế hoạch Ngài vạn kiếp còn nguyên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Định cương Chúa đến muôn đời bền vững,
      và kế hoạch vạn kiếp còn  nguyên.
      Thật vinh phúc dân tin _ kính Ngài,
      và nước là sản nghiệp Chúa chọn riêng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Thật vinh phúc quốc gia nào nhận Chúa
      và dân nào được Chúa chọn riêng.
      Từ thiên quốc cao sang _ Chúa ngự,
      và trông chừng mọi người khắp trần gian.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Từ thiên quốc Chúa uy quyền ngự lãm,
      và am tường người thế mọi nơi.
      Ngài tạo tác muôn muôn _ cõi lòng,
      việc chúng làm Ngài hằng thấu triệt luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Ngài đưa mắt dõi theo kẻ thờ kính,
      kẻ tin cậy lòng Chúa dủ thương.
      Hầu giải cứu qua tay _ tử thần,
      hồi cơ hàn Ngài nhìn tới dưỡng nuôi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Ngài đưa mắt dõi theo kẻ thờ kính,
      kẻ tin cậy lòng Chúa dủ thương.
      Vì vua thắng đâu do quân quốc nhiều,
      kẻ thoát nạn nào nhờ dũng lực đâu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      Đoàn con những vững tâm đợi trông Chúa,
      bởi Chúa hằng phù giúp chở che.
      Vì nơi Chúa hân hoan _ cõi lòng,
      và Danh Ngài là cùng đích đợi trông.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "15."
      Thật vinh phúc quốc gia nào nhận Chúa,
      và dân nào được Chúa chọn riêng.
      Hồng ân Chúa xin thương _ xuống đầy
      trên những người hằng bền vững cậy trông.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "16."
      \override Lyrics.LyricText.font-shape = #'italic
      Đoàn con những vững tâm đợi trông Chúa,
      bởi Chúa hằng phù giúp chở che.
      Hồng ân Chúa xin thương _ xuống đầy
      trên những người hằng bền vững cậy trông.
    }
  >>
}

loiPhanHai = \lyricmode {
  Phúc thay quốc gia Chúa chọn làm gia nghiệp.
}

loiPhanBa = \lyricmode {
  Người công chính hãy reo mừng trong Chúa,
  hãy hát khúc tân ca dâng kính Ngài.
}

loiPhanBon = \lyricmode {
  Do lời Chúa mà trời xanh được tác thành.
}

loiPhanNam = \lyricmode {
  Lạy Chúa, xin tỏ lượng từ bi Chúa cho chúng con
  như chúng con hằng cậy trông nơi Ngài.
}

loiPhanSau = \lyricmode {
  Tình thương Chúa tràn ngập khắp địa cầu.
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
        \line { \small "-ngày 21/12: câu 3, 9, 14 + Đ.2" }
        \line { \small "-Cn A /2MV: câu 4, 12, 16 + Đ.1" }
        \line { \small "-vọng PS (b.1): 4, 5, 10, 16 + Đ.5" }
        \line { \small "-t3 /PS: câu 3, 12, 16 + Đ.5" }
        \line { \small "-t7 /2PS: câu 1, 4, 12 + Đ.5" }
        \line { \small "-Cn A /5PS: câu 1, 3, 12 + Đ.5" }
        \line { \small "-t6 l /6TN: câu 8, 10, 11 + Đ.1" }
        \line { \small "-t5 l /8TN: câu 4, 5, 7 + Đ.3" }
        \line { \small "-t2 l /12TN: câu 10, 13, 16 + Đ.4" }
        \line { \small "-t4 l /14TN: câu 3, 8, 12 + Đ.4" }
        \line { \small "-Cn C /19TN: câu 2, 13, 15 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 c /21TN: câu 1, 3, 8 + Đ.5" }
        \line { \small "-t7 c /21TN: câu 10, 12, 14 + Đ.1" }
        \line { \small "-t4 c /22TN: câu 10, 11, 14 + Đ.1" }
        \line { \small "-t4 c /24TN: câu 3, 4, 15 + Đ.1" }
        \line { \small "-t6 c /28TN: câu 1, 4, 10 + Đ.1" }
        \line { \small "-Cn B /29TN: câu 4, 12, 16 + Đ.4" }
        \line { \small "-C.Ba Ngôi B: 4, 6, 12, 18 + Đ.1" }
        \line { \small "-nhận dự tòng: 4, 10, 12, 16 + Đ.1 hoặc Đ.4" }
        \line { \small "-khấn dòng: 3, 4, 9, 12, 14 + Đ.1" }
        \line { \small "-Thánh Tâm (NL): 1, 4, 9, 12, 14 + Đ.5" }
        \line { \small "-lễ Hôn Phối: câu 10, 14, 16 + Đ.5" }
        \line { \small "-" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
