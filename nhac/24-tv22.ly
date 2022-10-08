% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 22"
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
  c8. c16 a8 c |
  g4. f8 | f f e a |
  d2 |
  a8 f f16 (bf) a8 |
  g4. g8 |
  c a16 (g) c,8 e |
  f2 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      c8. c16 a8 c |
      g4. f8 |
      f f d g
    }
    {
      a8. g16 f8 f |
      e4. d8 |
      d c b! b
    }
  >>
  c2 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  a8 e16 (<f d>)
  <<
    {
      \voiceOne
      g8 f16 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c,8 c
    }
  >>
  \oneVoice
  <<
    {
      a'4. a8 |
      g c e, e |
      f2 \bar "|."
    }
    {
      f4. f8 |
      e d c c |
      a2
    }
  >>
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  c8. d16 f8 g |
  a2 |
  <<
    {
      bf8 bf bf d |
      g,4. g8 |
      c4 e,8 e |
      f2 \bar "|."
    }
    {
      g8 g g f |
      e4. d8 |
      e4 c8 c |
      a2
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Có Chúa chăn dắt tôi, nên tôi không còn thiếu gì,
      Nơi đồng cỏ xanh tươi, Ngài dẫn tôi vào nghỉ ngơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Dẫn tới bên suối trong cho tôi đây bồi dưỡng lại,
      Theo đường nẻo công minh, Ngài dẫn tôi vì Uy danh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Dẫu lúc qua lũng sâu, con đâu lo sợ khốn cùng,
      Bởi Ngài ở bên con, cầm sẵn côn trượng chở che.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa thiết con bửa ăn ngay khi quân thù đối mặt,
      Xức dầu tỏa hương thơm và cứ châm rượu đầy ly.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Chúa vẫn che chở con trong ân thiêng và nghĩa tình,
      Con được ở vương cung qua tháng năm dài triền miên.
    }
  >>
}

loiPhanHai = \lyricmode {
  Có Chúa chăn dắt tôi, nên tôi không còn thiếu gì.
}

loiPhanBa = \lyricmode {
  Tôi ở trong nhà Chúa những năm tháng dài triền miên.
}

loiPhanBon = \lyricmode {
  Dù qua thung lũng tối, con không lo mắc nạn vì Chúa ở cùng con.
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
        \line { \small "-t4 /1MV: cả 5 câu + Đ.2" }
        \line { \small "-t7 l /4TN: cả 5 câu + Đ.1" }
        \line { \small "-Cn B /16TN: cả 5 câu + Đ.1" }
        \line { \small "-t4 c /20TN: cả 5 câu + Đ.1" }
        \line { \small "-Cn A /28TN: cả 5 câu + Đ.1" }
        \line { \small "-t4 c /32TN: cả 5 câu + Đ.1" }
        \line { \small "-lễ Thánh Tâm C: cả 5 câu + Đ.1" }
        \line { \small "-Cn A /4MC: cả 5 câu + Đ.1" }
        \line { \small "-t2 /5MC: cả 5 câu + Đ.3" }
        \line { \small "-Cn A /4PS: cả 5 câu + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-lễ Chúa Kitô Vua: cả 5 câu + Đ.1" }
        \line { \small "-lễ tT. Mục tử: cả 5 câu + Đ.1" }
        \line { \small "-Nt trao kinh Lạy Cha: 5 câu + Đ.1" }
        \line { \small "-lễ Rửa tội: cả 5 câu : Đ.1" }
        \line { \small "-lễ Rửa tội trẻ nhỏ: 5 câu + Đ.1" }
        \line { \small "-lễ Thêm sức: cả 5 câu + Đ.1" }
        \line { \small "-lễ Truyền chức: cả 5 câu + Đ.1" }
        \line { \small "-lễ cầu hồn: 5 câu + Đ.1 hoặc Đ.3" }
        \line { \small "-an táng trẻ nhỏ: 5 câu + Đ.1 hoặc Đ.3" }
        \line { \small "-cầu hiệp nhất: cả 5 câu + Đ.1" }
        \line { \small "-lễ Mình Máu Chúa: 5 câu + Đ.1" }
        \line { \small "-kính tòa t.Phêrô: 5 câu + Đ.1" }
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
