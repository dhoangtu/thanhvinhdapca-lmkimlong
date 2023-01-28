% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 95"
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
  \partial 4 \tuplet 3/2 { a8 g f } |
  bf4 \tuplet 3/2 { g8 g bf } |
  c4 \tuplet 3/2 { c8 bf a } |
  d8. d16 \tuplet 3/2 { d8 bf a } |
  g4 \tuplet 3/2 { g8 f e } |
  a8. a16 \tuplet 3/2 { a8 c, g' }
  f4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      bf8. bf16 a8 g |
      c4 bf8 g
    }
    {
      f8 |
      g8. g16 f8 f |
      e4 g8 e
    }
  >>
  f2 ~ |
  f4 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      bf4 g |
      c8 c bf g
    }
    {
      f8 |
      g4 f |
      e8 e g e
    }
  >>
  f2 ~ |
  f4 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      a4 bf8 bf |
      bf4 c8 c |
      a a bf (a) |
      g2
    }
    {
      f8 |
      f4 g8 g |
      g4 a8 a |
      f f g (f) |
      c2
    }
  >>
  c8 c
  <<
    {
      a'16 (bf) a8 |
      g8.
    }
    {
      f16 (g) f8 |
      c8.
    }
  >>
  c16
  <<
    {
      \voiceOne
      g'16 (a) g8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      bf,8 c
    }
  >>
  \oneVoice
  <f a,>2 ~ |
  <f a,>4 \bar "|."
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a' (bf) a4 |
      g c,8 g' |
    }
    {
      f8 (g) f4 |
      bf,4 a8 bf
    }
  >>
  <<
    {
      \voiceOne
      g'8 (a) g4
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c,4 c8 ^(bf)
    }
  >>
  \oneVoice
  <f' a,>4 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      c8 |
      a g
    }
    {
      a8 |
      f c
    }
  >>
  <<
    {
      \voiceOne
      d16 (f) d8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      bf8 bf
    }
  >>
  \oneVoice
  <<
    {
      c4 g'8 g |
      f2 ~ |
      f4 \bar "|."
    }
    {
      a,4 bf8 c |
      a2 ~ |
      a4
    }
  >>
}

nhacPhanBay = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f8 |
  e f d c |
  <<
    {
      a'4. bf8 |
      bf g bf c
    }
    {
      f,4. g8 |
      d d g e
    }
  >>
  f4 \bar "|."
}

nhacPhanTam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      c8 |
      a4 a |
      bf4. d,8 |
      d4 c8 f |
      f4 \bar "|."
    }
    {
      a8 |
      f4 f |
      d4. c8 |
      bf4 bf8 bf |
      a4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hát lên mừng Chúa một bài ca mới.
      Hát lên mừng Chúa hỡi tất cả địa cầu,
      Hát lên mừng Chúa, hãy chúc tụng Thánh Danh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hát lên mừng Chúa một bài ca mới.
      Hát lên mừng Chúa hỡi tất cả địa cầu.
      Nói cho vạn quốc biết những kỳ công Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Phúc ân độ thế ngày ngày loan báo.
      Nói cho vạn quốc biết rõ vinh hiển Ngài,
      các dân đều thấy những vĩ nghiệp tay Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa cao trọng đáng ngàn lời cung chúc,
      Chí tôn khả úy Đấng sáng tạo cung trời,
      cao trổi vượt hết các ngẫu thần dân ngoại.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Chính tay Ngài đã tạo dựng trời cao,
      trước nhan cực thánh sáng rỡ vẻ oai hùng,
      khắp cung điện Chúa những dũng lực huy hoàng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy dâng về Chúa quyền lực vinh quang,
      hãy dâng về Chúa hỡi hết mọi dân tộc,
      hãy dâng về Chúa sáng láng ngợp Thánh Danh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Hãy bưng của lễ vào đền Thiên Chúa,
      Cúc cung thờ kính Chúa thánh thiện uy hùng.
      Tất cả hoàn vũ hãy kính sợ Thánh Nhan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Nói cho vạn quốc: Ngài là Thượng Đế,
      tác sinh hoàn vũ giữ gìn vững khôn chuyển rời,
      xét xử mọi nước đúng lối đường công bình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Đất mau nhảy múa, trời nào vui lên,
      Biển khơi gầm thét với tất cả hải vật,
      các cây rừng hãy hát xướng cùng nương đồng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Hát lên mừng Chúa vì Ngài ngự đến
      xét xử trần thế đúng phép công minh.
      Ngài xét xử vạn quốc, phán quyết Ngài công bình.
    }
  >>
}

loiPhanHai = \lyricmode {
  Thiên Chúa chúng ta ngự đến trong uy quyền.
}

loiPhanBa = \lyricmode {
  Đây Chúa ngự đến xét xử gian trần.
}

loiPhanBon = \lyricmode {
  Hôm nay Chúa Cứu Thế đã giáng sinh cho chúng ta,
  Người là Đức Ki -- tô, là Chúa chúng ta.
}

loiPhanNam = \lyricmode {
  Trời hãy vui lên và đất hãy reo mừng.
}

loiPhanSau = \lyricmode {
  Hãy đi rao giảng Tin Mừng khắp thế gian.
}

loiPhanBay = \lyricmode {
  Hãy loan báo cho mọi nước biết những kỳ công Chúa làm.
}

loiPhanTam = \lyricmode {
  Hãy dâng lên Chúa quyền lực và vinh quang.
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
        \line { \small "-t3 /2MV: câu 1, 8, 9, 10 + Đ.1" }
        \line { \small "-lễ đêm GS: câu 1, 3, 9, 10 + Đ.3" }
        \line { \small "-ngày 29/12: câu 1, 3, 5 + Đ.4" }
        \line { \small "-ngày 30/12: câu 6, 7, 8 + Đ.4" }
        \line { \small "-ngày 30/12: câu 1, 9, 10 + Đ.4" }
        \line { \small "-Cn C /2TN: câu 1, 3, 9, 10 + Đ.6" }
        \line { \small "-t5 /5PS: câu 1, 2, 8 + Đ.6" }
        \line { \small "-t6 c /8TN: câu 8, 9, 10 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 c /8TN: câu 8, 9, 10 + Đ.2" }
        \line { \small "-t2 c /21TN: câu 1, 3, 4 + Đ.6" }
        \line { \small "-t3 c /21TN: câu 8, 9, 10 + Đ.5" }
        \line { \small "-Cn A /22TN: câu 2, 4, 9, 10 + Đ.1" }
        \line { \small "-t2 l /22TN: câu 2, 4, 9, 10 + Đ.2" }
        \line { \small "-Cn A /29TN: câu 2, 4, 6, 8, 8 + Đ.7" }
        \line { \small "-t3 l /34TN: câu 8, 9, 10 + Đ.2" }
        \line { \small "-t.Mục tử: câu 1, 3, 6, 8 + Đ.6" }
        \line { \small "-ban Thêm sức: câu 1, 3, 5, 9 + Đ.6" }
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
      instrumentName = \markup { \bold "Đ.6" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBay
        }
      \new Lyrics \lyricsto beSop \loiPhanBay
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
      instrumentName = \markup { \bold "Đ.7" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanTam
        }
      \new Lyrics \lyricsto beSop \loiPhanTam
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
