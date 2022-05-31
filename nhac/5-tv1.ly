% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 1"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% Nhạc
nhacMauMot = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 c8 e16 (f) |
  d4.
  <<
    {
      e8 |
      f c g' g |
      e2 ~ |
      e8 e e a |
      a4. b8 |
      c4 g8 f |
      e2 ~ |
      e8 e c g' |
      g4. g8 |
      e a g g |
      c2 ~ |
      c4 \bar "|."
    }
    {
      c,8 |
      d a b b |
      c2 ~ |
      c8 c c e |
      f4. g8 |
      e4 e8 d |
      c2 ~ |
      c8 c a b |
      c4. d8 |
      c f e d |
      e2 ~ |
      e4
    }
  >>
}

% Lời
loiMauMot = \lyricmode {
  Từ thánh điện xin Chúa trợ giúp các bạn,
  Và từ Si -- on xin Chúa thương bảo vệ.
  Xin Ngài ban ơn theo lòng các bạn nguyện ước.
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
}

\markup {
  \fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t6 /2MV: cả 3 câu + Đ.1" }
        \line { \small "-Cn C /6TN: cả 3 câu + Đ.2" }
        \line { \small "-t5 l /7TN: cả 3 câu + " }
      }
    }
    \column {
      \left-align {
        \line { \small "-t5 l /27TN: cả 3 câu + Đ.2" }
        \line { \small "-t4 c /28TN: cả 3 câu + Đ.1" }
        \line { \small "-t5 l /29TN: cả 3 câu + Đ.2" }
        \line { \small "-t2 c /30TN: cả 3 câu + Đ.4" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t2 c /33TN: cả 3 câu + Đ.3" }
        \line { \small "-t5 sau lễ Tro: cả 3 câu + Đ2" }
        \line { \small "-t5 /2MC: cả 3 câu + Đ.2" }
        \line { \small "-lễ T.Nam Nữ: 3 câu + Đ.2" }
        \line { \small "-lễ tôn ĐVPhụ: 3 câu + Đ.2" }
      }
    }
  }
}

\score {
  <<
    \new Staff <<
        \clef treble
        \new Voice = beSop {
          \nhacMauMot
        }
      \new Lyrics \lyricsto beSop \loiMauMot
    >>
  >>
  \layout {
    \override Lyrics.LyricSpace.minimum-distance = #1.5
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
