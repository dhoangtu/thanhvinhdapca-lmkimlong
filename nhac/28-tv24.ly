% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 24"
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
  a4. f16 e |
  b'4
  \tuplet 3/2 {
    <<
      {
        \voiceOne
        c8
      }
      \new Voice = "splitpart" {
        \voiceTwo
        \tweak font-size #-2
        \parenthesize
        b8
      }
    >>
    \oneVoice
    a e'
  } |
  e4 r8 c16 e |
  d8. b16 \tuplet 3/2 { b8 c b } |
  a2 ~ |
  a4 r8 e |
  e4. e16 e |
  g4 \tuplet 3/2 { a8 d, e } |
  e4 r8 e |
  c'4. c16 d |
  b4 \tuplet 3/2 { e8 b c } |
  a4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  <<
    {
      c'2 |
      r8 b b b |
      a4 c8 b |
      e2 \bar "|."
    }
    {
      a,2 |
      r8 e e d |
      c4 a'8 a |
      gs2
    }
  >>
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  <<
    {
      c'4 b8 a |
      b4. e8 |
      e (d) c (b)
    }
    {
      a4 g8 f |
      e4. c'8 |
      c (b) a (gs)
    }
  >>
  a2 ~ |
  a4 r \bar "|."
}

nhacPhanBon = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  <<
    {
      c'8. b16 b8 a |
      e'4.
    }
    {
      a,8. gs16 gs8 e |
      c'4.
    }
  >>
  <<
    {
      \voiceOne
      d8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b16 (a)
    }
  >>
  \oneVoice
  <<
    {
      b8 b d e
    }
    {
      gs, gs gs gs
    }
  >>
  a2 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8 a16 a |
  e8. e16
  <<
    {
      c'8 a b8. b16 d8 e |
      c4 b8 e
    }
    {
      a,8 f |
      e8. e16 b'8 c |
      a4 a8 gs
    }
  >>
  a2 \bar "|."
}

nhacPhanSau = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  <c' a>4
  <<
    {
      \voiceOne
      b8 c16 (b)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      gs8 gs
    }
  >>
  \oneVoice
  a4.
  <<
    {
      a8 |
      a d
    }
    {
      g,8 |
      f f
    }
  >>
  <<
    {
      \voiceOne
      c'8 (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      a4
    }
  >>
  \oneVoice
  <e' gs,>2 \bar "|."
}

nhacPhanBay = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8 a8 |
  f4 e8
  <<
    {
      c'8 |
      c8. a16 a8 a |
      d4. d8 |
      e4 c8 d |
      c4. e8 |
      d e c (b)
    }
    {
      a8 |
      a8. f16 e8 c |
      f4. g8 |
      c4 a8 b |
      a4. c8 |
      b c a (gs)
    }
  >>
  a2 ~ |
  a4 r \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Con chẳng hổ ngươi tin cậy Chúa mãi,
      và đối phương không vui sướng nhạo cười.
      Chỉ người từng bội vong mới bị khinh khi,
      còn con tin Chúa luôn nào đâu bẽ bàng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin chỉ dậy con biết đường lối Chúa
      và dẫn con theo chân lý của Ngài.
      Vì ngài là Thàn Linh tế độ cho con,
      ngày đêm con vững tin lòng thương xót Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Xin dủ lòng thương nhớ tình nghĩa cũ,
      Ngài đã ban qua muôn thuở muôn đời.
      Tội tình của tuổi thơ Chúa đừng ghi tâm,
      mà xin luôn nhớ con vì ân nghĩa Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin chỉ đường cho những kẻ lỡ bước,
      vì Chúa đây luôn nhân ái chân thực.
      Dìu kẻ nghèo hèn theo lối đường công minh,
      dạy con luôn vững tâm tìm theo lối Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Bao nẻo đường Chúa thảy đều nghĩa tín
      cùng nhưng ai tuân Gia ước của ngài.
      Tội tinh nặng nề con Chúa hãy dung tha,
      và xin thương xót con vì danh thánh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Bao nẻo đường Chúa thảy đều nghĩa tín
      cùng những ai tuân Giao ước của Ngài.
      Tình Ngài dành tặng ai kính sợ Tôn Danh
      và thương cho thấu tri trọn Giao ước Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Xin hãy ủi an cõi lòng héo hắt
      và cứu con cho qua bước cơ cùng.
      Ngài nhìn cảnh  lầm than khốn cực con đây
      mà thương tha thứ cho ngàn muôn lỗi lầm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin hãy ủi an cõi lòng héo hắt
      và cứu con cho qua bước cơ cùng.
      Nguyện Ngài bảo toàn cho tính mạng con đây,
      đừng để con hổ người vì nương náu Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Xin bảo toàn con,
      \markup { \underline \italic "xin" }
      hãy cứu thoát khỏi hổ ngươi khi nương náu bên Ngài.
      Lòng này nguyện sạch trong, chính trực khôn ngơi,
      cậy trông nơi Chúa luôn, Ngài thương giữ gìn.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, con nâng tâm hồn lên cùng Chúa.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, xin dạy con lối bước của Ngài.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, ai trông cậy Chúa đâu phải hổ ngươi thất vọng.
}

loiPhanNam = \lyricmode {
  Hãy đứng dậy và ngẩng đầu lên vì ơn cứu độ đã đến gần.
}

loiPhanSau = \lyricmode {
  Lạy Chúa, xin nhớ lại lượng từ bi của Chúa.
}

loiPhanBay = \lyricmode {
  Tất cả đường lối Chúa đều là từ bi,
  trung tín dành cho ai giữ Giao ước của Ngài.
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
        \line { \small "-Cn C /1MV: câu 2, 4, 5 + Đ.1" }
        \line { \small "-t2 /3MV: câu 2, 3, 4 + Đ.2" }
        \line { \small "-ngày 23/12: câu 2, 4, 6 + Đ.4" }
        \line { \small "-Cn B /3TN: câu 2, 3, 4 + Đ.2" }
        \line { \small "-t4 l /9TN: câu 1, 2, 3, 4 + Đ.1" }
        \line { \small "-t5 c /9TN: câu 2, 4, 6 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { " " }
        \line { \small "-Cn A /26TN: câu 2, 3, 4 + Đ.5" }
        \line { \small "-Cn B /1MC: câu 2, 3, 4 + Đ.6" }
        \line { \small "-t3 /3MC: câu 2, 3, 4 + Đ.5" }
        \line { \small "-Cầu hồn-an táng: 3, 7, 9 + Đ.1 hoặc Đ.3" }
        \line { \small "-An táng trẻ chưa R.Tội: 2, 4, 8 + Đ.1" }
        \line { \small "-lễ Thánh Tâm (NL): 2, 3, 4, 6 + Đ.5" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.5
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
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
