% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 89"
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
  g8. g16 a8 f ~ |
  f g16 (f) d8 c |
  d4 r8 d |
  d8. d16 d8 bf' ~ |
  bf a g a |
  a4 a8 d |
  bf (c) d bf |
  g4. bf8 |
  a4 a8 c |
  bf4. c8 |
  d2 ~ |
  d4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key bf \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      bf'2 |
      r8 a
    }
    {
      g2 |
      r8 d
    }
  >>
  <<
    {
      \voiceOne
      a'8 bf16 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c,8 c
    }
  >>
  \oneVoice
  <<
    {
      g'4 r8 d |
      bf' g
    }
    {
      bf,4 r8 d |
      g d
    }
  >>
  <<
    {
      \voiceOne
      c'8 bf16 (c)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      ef,8 g
    }
  >>
  \oneVoice
  <<
    {
      d'2 ~ |
      d8 d, bf' (a)
    }
    {
      fs2 ~ |
      fs8 d g (fs)
    }
  >>
  g2 ~ |
  g4 r \bar "|."
}

nhacPhanBa = \relative c' {
  \key bf \major
  \time 2/4
  \partial 4
  d8
  <<
    {
      bf' |
      a4. a8 |
      a8. bf16 a8 g |
      c c4
    }
    {
      g8 |
      fs4. fs8 |
      fs8. g16 fs8 d |
      ef ef4
    }
  >>
  <<
    {
      \voiceOne
      bf'16 (c)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      g8
    }
  >>
  \oneVoice
  <<
    {
      d'2 ~ |
      d4 bf8 a |
      a4. d8 |
      a bf a4 |
    }
    {
      fs2 ~ |
      fs4 g8 c, |
      d4. d8 |
      d g fs4
    }
  >>
  g2 \bar "|."
}

nhacPhanBon = \relative c' {
  \key bf \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      bf'8 a g (c) |
      d4. d,8 |
      a' bf a4
    }
    {
      g8 d ef (g) |
      fs4. d8 |
      d g fs4
    }
  >>
  g2 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Ngay khi núi đồi chưa được tạo thành,
      địa cầu và hoàn vũ chưa được khai sinh,
      Từ muôn thuở đến muôn đời, Chúa ơi,
      Ngài vẫn là Thiên Chúa.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Đây Thiên Chúa truyền con người trở về:
      trở về cùng bụi cát, mau phàm nhân ơi.
      Ngàn năm nào khác một ngày mới qua,
      tựa canh tàn đêm vắng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Tan như giấc mộng khi Ngài cuộn đi,
      tựa cỏ ngoài đồng mới trổ mọc ban mai,
      bình minh vừa mới vươn dậy nở hoa,
      hoàng hôn vội khô héo.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Gom niên tuế lại trong vòng bảy chục,
      mà dù mạnh giỏi cũng bát tuần đâu hơn,
      Hầu như trọn kiếp chỉ toàn khổ đau,
      đời như vụt tan biến.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Ôi Thiên Cháu đợi bao giờ trở lại,
      mà chạnh lòng nhìn đến thương bầy tôi đây,
      Và răn dạy tính sổ đời chúng con,
      hầu thêm phần khôn khéo.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Cho ban sáng được no thỏa tình Ngài,
      để ngày ngày mừng rỡ vang lời hoan ca,
      bù bao ngày nếm khổ nhục, Chúa ơi,
      Ngài ban niềm vui sướng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Cho ban sáng được no thỏa tình Ngài,
      để ngày ngày mừng rỡ vang lời hoan ca,
      Bầy tôi được thấy công trình Chúa đây,
      và miêu duệ chiêm bái.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Mong ân nghĩa Ngài xuống trên đoàn con,
      Vì Ngài thực là Chúa của đoàn con luôn.
      Mọi công việc chúng con làm, Chúa ơi,
      Ngài bảo toàn kiên vững.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, qua bao thế hệ, Ngài vẫn là nơi ẩn náu của chúng con.
}

loiPhanBa = \lyricmode {
  Từ sớm mai xin cho chúng con được no say tình Chúa
  để ngày ngày được vui sướng hoan ca.
}

loiPhanBon = \lyricmode {
  Lạy Chúa xin củng cố việc tay chúng con làm.
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
        \line { \small "-t7 l /5TN: câu 1, 2, 3, 5 + Đ.1" }
        \line { \small "-t3 c /9TN: câu 1, 2, 4, 7 + Đ.1" }
        \line { \small "-t5 l /21TN: câu 2, 5, 6, 8 + Đ.2" }
        \line { \small "-Cn C /23TN: câu 2, 3, 5, 8 + Đ.1" }
        \line { \small "-t5 c /25TN: câu 2, 3, 5, 8 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-Cn C /18TN: câu 2, 3, 5, 7 + Đ.1" }
        \line { \small "-t7 c /25TN: câu 2, 3, 5, 8 + Đ.1" }
        \line { \small "-Cn B /28TN: câu 5, 6, 8 + Đ.2" }
        \line { \small "-Đầu năm: câu 1, 2, 3, 5, 6 + Đ.3" }
        \line { \small "-Thánh hóa công việc: câu 1, 2, 3, 5, 6 + Đ.3" }
        \line { \small "-T. Giuse lao động: câu 1, 2, 5, 6 + Đ.3" }
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
