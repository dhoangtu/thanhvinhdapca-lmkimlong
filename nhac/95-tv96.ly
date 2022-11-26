% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 96"
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
  c4. f,8 |
  g2 ~ |
  g8 a16 a a8 g16 (f) |
  d8 c16 c d16 (f) g8 |
  g4 r8 bf16 bf |
  d8 bf g (f) |
  e2 |
  r8 d d e |
  c c16 c g'8 g |
  f4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a16 (bf) |
      g4 a |
      a4. g8 |
      c d
    }
    {
      f,16 (g) |
      e4 f |
      f4. f8 |
      e f
    }
  >>
  <<
    {
      \voiceOne
      g16 (c) a (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e8 e
    }
  >>
  \oneVoice
  f2 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      f g4 f8 |
      d2 |
      r8 c a' a |
      g g
    }
    {
      f8 |
      d c4 a8 |
      bf2 |
      r8 c f f |
      e e
    }
  >>
  <<
    {
      \voiceOne
      a16 (c) a (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e8 e
    }
  >>
  \oneVoice
  f2 ~ |
  f4 r \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      a2 |
      r8 bf bf bf |
      d, (f) g a |
      g4 r8 g |
      c4 f,8 bf |
      a g a (g)
    }
    {
      f8 |
      f2 |
      r8 d d d |
      bf (a) c f |
      e4 r8 c |
      a4 d8 g |
      f e f (e)
    }
  >>
  f2 ~ |
  f4 r \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Chúa làm Vua, trái đất hãy nhảy mừng, ngàn quần đảo reo vui.
      Mây u ám phủ quanh Ngài,
      công minh chính trực là bệ cung ngai Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Trước Thần Nhan, chói sáng ánh lửa hồng,
      diệt địch thủ tiêu vong.
      Bao tia chớp soi gian trần.
      Ngay khi ngắm nhìn địa cầu đã khiếp kinh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Núi vội tan giống sáp trước nhan Ngài,
      là hoàng thượng dương gian.
      Công minh Chúa vang cung trời.
      Muôn dân ngắm nhìn tận tường ánh Thánh Nhan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa làm Vua, trái đất hãy nhảy mừng,
      ngàn quần đảo reo vui.
      Công minh Chúa vang cung trời.
      Muôn dân ngắm nhìn tận tường ánh Thánh Nhan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Cõi trời cao mãi mãi sẽ loan truyền rằng Ngài thật công minh,
      muôn dân thấy vinh hiển Ngài,
      bao nhiêu thánh thần đều phục bái Chúa đây.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Hết những ai kính bái các ngẫu thần đều phải hổ ngươi thôi,
      huênh hoang với bao ảo vật,
      bao nhiêu thánh thần đều phục bái Chúa đây.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Chính vì đây: Chúa rất đỗi cao trọng,
      và vượt trổi nơi nơi.
      Muôn tâu Chúa,
      ôi siêu việt trên muôn thánh thần và toàn cõi thế gian.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Hết những ai biết gớm ghét gian tà
      thì được Ngài yêu thương.
      Ai trung hiếu Chúa giữ gìn,
      ra tay cứu mạng khỏi bè lũ ác nhân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Sáng bừng lên chói lói chiếu kẻ lành,
      ngời rạng kẻ công minh.
      Nơi Nhan Chúa hãy vui mừng,
      ai luôn chính trực hãy cảm mến Thánh Danh.
    }
  >>
}

loiPhanHai = \lyricmode {
  Trước Nhan Thánh Chúa, người công chính hãy vui mừng.
}

loiPhanBa = \lyricmode {
  Chúa là Vua hiển trị, là Đấng Tối Cao trên khắp địa cầu.
}

loiPhanBon = \lyricmode {
  Hôm nay ánh sáng chiếu tỏa trên chúng ta,
  vì Chúa đà giáng sinh cho chúng ta.
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
        \line { \small "-lễ rạng đông GS: câu 4, 9 + Đ.3" }
        \line { \small "-T.Gioan (27/12): câu 1, 3, 9 + Đ.1" }
        \line { \small "-t2 l /1TN: câu 1, 5, 7 + Đ.2" }
        \line { \small "-t5 c /11TN: câu 1, 2, 3, 6 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t6 l /21TN: câu 1, 3, 8, 9 + Đ.1" }
        \line { \small "-t7 l /27TN: câu 1, 3, 9 + Đ.1" }
        \line { \small "-Cn C /7PS: câu 1, 5, 7 + Đ.2" }
        \line { \small "-Chúa hiển dung: câu 4, 7 + Đ.2" }
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
