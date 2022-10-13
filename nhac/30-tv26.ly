% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 26"
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
  \partial 4. e8 c f |
  f4. d8 |
  a' a fs4 |
  g8 c a a16 (c) |
  d2 ~ |
  d8 c c c |
  e (d16 c) e,8 g |
  a4. g8 |
  d f e (d) |
  c2 ~ |
  c8 r \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4.
  <<
    {
      c8 e, a |
      a4. g8 |
      d' d b4 |
      c2 ~ |
      c8 \bar "|."
    }
    {
      e,8 c f |
      f4. e8 |
      f f g4 |
      e2 ~ |
      e8
    }
  >>
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  \partial 4. e8 c f |
  f4. d8 |
  <a' c,>8 <a c,>
  <<
    {
      \voiceOne
      fs4
    }
    \new Voice = "splitpart" {
      \voiceTwo
      d8 (c)
    }
  >>
  \oneVoice
  <<
    {
      g'8 c b b |
      c2 ~ |
      c8 \bar "|."
    }
    {
      b,8 a d d |
      e2 ~ |
      e8
    }
  >>
}

nhacPhanBon = \relative c' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      e8 (g) |
      a4. g8 |
      d g
    }
    {
      c,8 (e) |
      f4. c8 |
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
  c8 \bar "|."
}

nhacPhanNam = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 e8 e |
  c8. f16 d8
  <<
    {
      d8 |
      g8. g16 e8 e |
      a4. a8 |
      g d'4 c8 |
      c2 ~ |
      c8 \bar "|."
    }
    {
      c,8 |
      b8. b16 c8 c |
      f4. f8 |
      e f4 e8 |
      e2 ~ |
      e8
    }
  >>
}

nhacPhanSau = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 r8 c |
  c8. e16 f8 e |
  d4.
  <<
    {
      d8 |
      d d
    }
    {
      c |
      b b
    }
  >>
  <<
    {
      \voiceOne
      g'8 e16 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b,8 c
    }
  >>
  \oneVoice
  <<
    {
      a'4. b8 |
      g4 a |
      c2 ~ |
      c8 \bar "|."
    }
    {
      f,4. g8 |
      e4 f |
      e2 ~ |
      e8
    }
  >>
}

nhacPhanBay = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4 r8
  <<
    {
      g8 |
      e f g4 |
      g r8 g |
      d' d b4 |
      c2 ~ |
      c8 \bar "|."
    }
    {
      e,8 |
      c d c4 |
      b r8 c |
      f f g4 |
      e2 ~ |
      e8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Chúa là ánh sáng, là Đấng cứu độ tôi, tôi còn sợ ai?
      Ngài là thành lũy bảo vệ tôi, tôi còn phải lo gì?
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Ác thù xấn tới định nuốt sống mạng tôi, tôi nào sợ chi.
      Vì nào ngờ chính địch thù tôi nay trượt té lộn nhào.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Dẫn vạn lính chiến dồn tới xiết vòng vây, tôi nào sợ chi.
      Dù nhập trận chiến lòng tôi đây luôn bền vững tin cậy.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Kiếm tìm khấn ước được sớm tối ẩn thân trong đền thờ Chúa,
      để được nhìn ngắm Ngài cao sang,
      trông đền thánh huy hoàng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Lúc gặp khốn khó, nguyện Chúa giữ gìn con trong đền thờ Chúa,
      đặt để thật kín ở cung lâu, trên tảng đá an toàn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Lúc cầu khấn Chúa, nguyện Ngài đáp lời con,
      xin Ngài dủ thương. Về Ngài lòng vẫn nhủ thầm luôn:
      mau tìm thánh nhan Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Lúc cầu khấn Chúa, nguyện Ngài đáp lời con, xin Ngài dủ thương.
      Vì hồn này vẫn tìm Tôn Nahn, xin Ngài chớ ẩn mặt.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Con tìm kiếm Chúa, Ngài chớ lánh mặt đi,
      xin đừng ruồng rẫy.
      Lạy Ngài là Đấng phù trợ con, xin đừng nỡ xua từ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Khấn cầu tới Chúa là Đấng cứu độ con, chỉ đường nẻo Chúa,
      vì nhiều người vẫn rình hại con, xin dìu bước an bình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Tin rằng sẽ thấy lộc phúc Chúa tặng ban trong miền kẻ sống.
      Cậy nhờ vào Chúa, mạnh bạo lên, can trường vững tin Ngài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúa là ánh sáng, là Đấng cứu độ tôi.
}

loiPhanBa = \lyricmode {
  Chúa là ánh sáng, là Đấng cứu độ tôi, tôi còn sợ ai?
}

loiPhanBon = \lyricmode {
  Lạy Chúa, con tìm thánh nhan Ngài.
}

loiPhanNam = \lyricmode {
  Tôi tin rằng sẽ được nhìn xem ơn lành của Chúa
  trong miền đất nhân sinh.
}

loiPhanSau = \lyricmode {
  Một điều tôi kiếm, tôi xin
  là được ở trong nhà Chúa suốt cuộc đời tôi.
}

loiPhanBay = \lyricmode {
  Xin đừng bỏ rơi con, lạy Đấng cứu độ con.
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
        \line { \small "-t6 /1MV: câu 1, 4, 10 + Đ.1" }
        \line { \small "-t6 l /4TN: câu 1, 3, 5, 8 + Đ.1" }
        \line { \small "-t6 c /10TN: câu 6, 8, 10 + Đ.3" }
        \line { \small "-Cn A /3TN: câu 1, 4, 10 + Đ.1" }
        \line { \small "-t3 l /22TN: câu 1, 4, 10 + Đ.4" }
        \line { \small "-t5 c /26TN: câu 1, 4, 10 + Đ.4" }
        \line { \small "-t4 c /31TN: câu 1, 4, 10 + Đ.1" }
        \line { \small "-t5 l /31TN: câu 1, 4, 10 + Đ.4" }
        \line { \small "-Cn C /2MC: câu 1, 6, 8, 10 + Đ.2" }
        \line { \small "-ad lib. /4MC: câu 1, 6, 10 + Đ.2" }
        \line { \small "-t2 Tuần Thánh: câu 1, 2, 3, 10 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { " " }
        \line { \small "-t6 /2PS: câu 1, 2, 3, 10 + Đ.1" }
        \line { \small "-Cn A /7PS: câu 1, 4, 6 + Đ.4" }
        \line { \small "-Rửa tội: câu 1, 4, 8, 10 + Đ.1" }
        \line { \small "-Khấn dòng: câu 1, 4, 5, 8, 9 + Đ.1" }
        \line { \small "-Cầu ơn Th.Triệu: câu 1, 4, 5, 8, 9 + Đ.3" }
        \line { \small "-Khi bị bách hại: 1, 2, 3, 5 + Đ.1 hoặc Đ.6" }
        \line { \small "-Cầu hồn: câu 1, 4, 7, 10 + Đ.1 hoặc Đ.4" }
        \line { \small "-Cầu cho Hội Thánh: 1, 2, 3, 5 + Đ.6" }
        \line { \small "-Cầu cho linh mục: 1, 4, 5, 8 + Đ.3" }
        \line { \small "-Cầu cho Tu sĩ: 1, 2, 3, 5 + Đ.3" }
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
