% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 36"
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
  \partial 8 c8 |
  a (g) f (g) |
  a4 \tuplet 3/2 { d,8 d df } |
  c4 r8 c16 f |
  e8 f g a |
  a4 \tuplet 3/2 { f8 bf a } |
  g2 ~ |
  g4 r8 f \break
  bf4. bf16 bf |
  bf8 g4 bf8 |
  c4 r8 g |
  g c a (g) |
  f (e) d g |
  e4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  d, (e)
  <<
    {
      f (g) |
      a4. f8 |
      bf8. g16 g8 c
    }
    {
      d,8 (e) |
      f4. ef8 |
      d8. d16 e8 e
    }
  >>
  f2 ~ |
  f4 r8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 c4 |
  d8 (e) f8 (
  <<
    {
      g) |
      a4. c8 |
      e,4 g8 f |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      e) |
      f4. f8 |
      c4 bf8 bf |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a16 a |
  a8 f f
  <<
    {
      a8 |
      bf4. c8 |
      e,4 g8 f |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      f8 |
      d4. d8 |
      c4 bf8 bf |
      a2 ~ |
      a4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy tin tưởng Chúa và làm việc lành
      thì sẽ được ở trong đất nước và sống khang an.
      Bạn hãy lấy chính Chúa làm niềm vui,
      thì Ngài sẽ cho bạn được thỏa lòng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy trao gửi Chúa đường đời của bạn,
      và hãy trọn niềm tin kính Chúa,
      Ngài sẽ ra tay.
      Bạn sẽ sáng chính nghĩa tựa bình minh,
      quyền lợi sẽ huy hoàng tựa chính ngọ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chúa luôn hiểu thấu đời người thiện toàn,
      và gia nghiệp họ tay Chúa giữu bền vững muôn năm.
      Dù lúc mắc khốn khó chẳng hổ ngươi,
      và họ sẽ no tỏa ngày đói nghèo.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa luôn hiểu thấu đời người thiện toàn,
      và gia nghiệp họ tay Chúa giữu bền vững muôn năm,
      Ngài giúp khiến lối bước họ kiên vững,
      vì Ngài vẫn ưa chuộng đường lối họ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Chúa thương dìu dắt đường đời mọi người,
      và ban trợ họ luôn vững bước,
      và thỏa vui luôn.
      Bởi thế dẫu có vấp chẳng gục ngã,
      vì ngài nắm tay để dìu dắt họ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Tránh xa điều dữ và làm việc lành,
      bạn sẽ được ổn cư mãi mãi và sống an vui,
      vì Chúa vẫn thích thú điều ngay chính,
      chẳng hề bỏ rơi kẻ nào tín thành.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Tránh xa điều dữ và làm việc lành,
      bạn sẽ được ổn cư mãi và sống an vui,
      vì Chúa sẽ dẫn dắt người công chính
      vào miền đất gia nghiệp ở suốt đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Lưỡi luôn chỉ nói điều gì trọn lành
      và môi miệng người công chính vẫn niệm lẽ khôn ngoan
      Luật Chúa nhớ khắc mãi vào tâm trí,
      từng nhịp bước không xiêu vẹo chút nào.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Chính nhân được Chúa phù trợ giữ gìn,
      và cứu độ chở che những lúc gặp bước gian nan,
      từng phút Chúa đáp cứu và giải thoát,
      vì họ vẫn nương ẩn ở sát Ngài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Những người công chính được Chúa ban ơn cứu độ.
}

loiPhanBa = \lyricmode {
  Miệng người công chính những niệm lẽ khôn ngoan.
}

loiPhanBon = \lyricmode {
  Hãy ký thác đường đời cho Chúa, chính Ngài sẽ ra tay.
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
        \line { \small "-t6 l /3TN: câu 1, 3, 5, 9 + Đ.1" }
        \line { \small "-t3 c /5TN: câu 2, 8, 9 + Đ.2" }
        \line { \small "-t3 l /7TN: câu 1, 3, 6, 9 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 l /14TN: câu 1, 3, 6, 9 + Đ.1" }
        \line { \small "-t6 c /22TN: câu 1, 2, 6, 9 + Đ.1" }
        \line { \small "-t3 c /32TN: câu 1, 4, 7 + Đ.1" }
        \line { \small "-T.Tiến sĩ: câu 1, 2, 8 + Đ.2" }
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
