% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 33"
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
  \key g \major
  \time 2/4
  b8. b16 e,8 g |
  a4.
  <<
    {
      b8 |
      c c4 a8
    }
    {
      g8 |
      e e4 g8
    }
  >>
  \grace { a16 (} <d) fs,>4. <fs, d>8 |
  g2 ~ |
  g4 \bar "|."
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  g8 (fs) d d |
  e (g4) a8 |
  a4.
  <<
    {
      a8 |
      d c a4
    }
    {
      g8 |
      fs fs fs4
    }
  >>
  g2 ~ |
  g4 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b8 d g, (a) |
      e4. e8 |
      d4 g8 a |
      b2 \bar "|."
    }
    {
      g8 fs g (d) |
      c4. c8 |
      b4 b8 d |
      g2
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b8. b16 g8 a |
      c4. d8 |
      fs, a g4 |
      g2 \bar "|."
    }
    {
      g8. g16 e8 d |
      e4. e8 |
      d c c4 |
      b2
    }
  >>
}

nhacPhanNam = \relative c'' {
  \key g \major
  \time 2/4
  b8 b e, (g) |
  <<
    {
      a4. b8 |
      d, a' fs a |
      g2 \bar "|."
    }
    {
      d4. d8 |
      b c d c |
      b2
    }
  >>
}

nhacPhanSau = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b8 b b (c) |
      a4. a8 |
      a d b (a) |
      g2 \bar "|."
    }
    {
      g8 g g (a) |
      fs4. e8 |
      d d d (c) |
      b2
    }
  >>
}

nhacPhanBay = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b4 g8 g |
      c4. a8 |
      a c fs, fs |
      g2 \bar "|."
    }
    {
      g4 f!8 f |
      e4. e8 |
      d e d d |
      b2
    }
  >>
}

nhacPhanTam = \relative c'' {
  \key g \major
  \time 2/4
  g8
  <<
    {
      a8 b d |
      e,4. g8 |
      a4 r8 fs |
      a a
    }
    {
      fs8 e d |
      c4. e8 |
      d4 r8 d |
      c c
    }
  >>
  <<
    {
      \voiceOne
      fs16 (e) d8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c c
    }
  >>
  \oneVoice
  <g' b,>2 ~ |
  <g b,>4 \bar "|."
}

nhacPhanChin = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b8 b a g |
      e4. fs8 |
      d g fs (g) |
      a4. a8 |
      g2 ~ |
      g4 \bar "|."
    }
    {
      g8 g d d |
      c4. c8 |
      b b a (b) |
      c4. d8 |
      b2 ~ |
      b4
    }
  >>
}

nhacPhanMuoi = \relative c'' {
  \key g \major
  \time 2/4
  g8 e fs (g) |
  a8. a16 g8
  <<
    {
      g8 |
      c4. b8 |
      a d b (fs) |
      g2 ~ |
      g4 \bar "|."
    }
    {
      f!8 |
      e4. g8 |
      fs e d (c) |
      b2 ~ |
      b4
    }
  >>
}

nhacPhanMuoiMot = \relative c'' {
  \key g \major
  \time 2/4
  g8. g16 \tuplet 3/2 { g8 g fs } |
  b4 \tuplet 3/2 { c8 e a, } |
  a fs d' c |
  b2 b8. b16 \tuplet 3/2 { g8 a b } |
  e,4 \tuplet 3/2 { e8 g e } |
  d8. a'16 \tuplet 3/2 { c8 fs, g } |
  g2 \bar "||"
}

% Lời
loiPhanMot = \lyricmode {
  Hãy nếm thử mà coi cho biết Chúa thiện hảo dường bao.
}

loiPhanHai = \lyricmode {
  Những người nghèo khổ kêu xin và Chúa đã nhậm lời.
}

loiPhanBa = \lyricmode {
  Tôi sẽ không ngừng, không ngừng ngợi khen Chúa.
}

loiPhanBon = \lyricmode {
  Chúa cứu người công chính thoát mọi nỗi gian truân.
}

loiPhanNam = \lyricmode {
  Chúa vẫn ở bên những người cõi lòng nát tan.
}

loiPhanSau = \lyricmode {
  Chúa đã cứu tôi khỏi mọi nỗi kinh hoàng.
}

loiPhanBay = \lyricmode {
  Hãy nhìn về Cháu để được hớn hở mừng vui.
}

loiPhanTam = \lyricmode {
  Người công chính những gặp gian truân,
  nhưng Chúa cứu nguy họ luôn.
}

loiPhanChin = \lyricmode {
  Hãy đến nghe ta dạy biết đường tôn sợ Chúa, hỡi con.
}

loiPhanMuoi = \lyricmode {
  Thiên thần của Chúa xây dựng đồn lũy quanh kẻ kính sợ Ngài.
}

loiPhanMuoiMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Tôi luôn luôn ca tụng Chúa,
      câu hát mừng Ngài chẳng ngớt trên môi.
      Chúa đã làm tôi hãnh diện,
      xin các bạn nghèo nghe nói mà vui lên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin theo tôi ca ngợi Chúa,
      ta hãy hiệp lời mừng chúc Uy Danh,
      Chúa đáp lời tôi khấn cầu,
      cho thoát mọi điều kinh hãi và lo âu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Ai hân hoan trông về Chúa,
      luôn sẽ chẳng còn nhục nhã hổ ngươi.
      Tiếng kẻ nghèo đây khấn nài,
      Thiên Chúa ưng nhận cho thoát mọi nguy nan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Bao cơ binh xây đồn lũy quanh kẻ cậy Ngài giải thoát cứu nguy.
      Hãy nếm Ngài bao tốt lành,
      Nương náu bên Ngài vinh phúc thực khôn vơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Dân riêng ơi, tôn sợ Chúa,
      ai kính sợ Ngài chẳng thiếu thốn chi.
      Phú quý rầy nên khó nghèo,
      Ai kiếm trông Ngài không thiếu hụt khi nao.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Con ơi nghe ta dậy dỗ cho biết đường mà thờ kính Chúa luôn.
      Hỡi những người mong sống còn,
      mong hưởng những ngày vinh phúc và khang an.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Ta luôn trông coi miệng lưỡi không nói lời nào gian ác điêu ngoa.
      Sống tốt lành, xa ác tà,
      Ăn ở thuận hòa, trông kiếm bình an luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Bôi tên luôn nơi trần thế, bao lũ bạo tàn bị Chúa tru di.
      Chúa đoái nhìn ai chính trực,
      Luôn lắng tai mà nghe tiếng họ kêu van.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Khi nguy nan kêu cầu Chúa, nên Chúa nhậm lời giải thoát khang an.
      Chúa ở gần bao tấm lòng tan vỡ ê chề để cứu độ cho luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Ai công minh luôn gặp khó, nhưng Chúa dủ tình hằng cứu thoát cho.
      Chúa giữ gìn xương cốt họ, không để khúc nào bị gẫy dập chi đâu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Quân gian manh gây tội lỗi,
      kẻ ghét người lành bị án tiêu vong.
      Chúa cứu mạng tôi tớ Ngài,
      Nương náu bên Ngài không lãnh phạt khi nao.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Bôi tên luôn nơi trần thế bao lũ bạo tàn bị Chúa tru di.
      Chúa đáp lời ai chính trực,
      Kêu khấn lên Ngài xin cứu khỏi gian nguy.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Bao tâm can như rạn vỡ, luôn những được Ngài gần gũi cứu nguy.
      Chúa cứu mạng tôi tớ Ngài.
      Nương náu bên Ngài không lãnh phạt khi nao.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      Bao tâm can như rạn vỡ, luôn những được Ngài gẫn gũi cứu nguy.
      Kẻ chính trực hay mắc nạn,
      Nhưng Chúa thương tình luôn giúp họ kinh qua.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "15."
      Ai công minh luôn được giữ xương cốt vẹn toàn từng khúc y nguyên.
      Chúa cứu mạng tôi tớ Ngài.
      Nương náu bên Ngài không lãnh phạt khi nao.
    }
  >>
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
        \line { \small "-t3 /3MV: câu 1, 3, 12, 13 + Đ.2" }
        \line { \small "-t3 /1MC: câu 2, 3, 8, 9 + Đ.4" }
        \line { \small "-Cn C /4MC: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t6 /4MC: câu 12, 14, 15 + Đ.5" }
        \line { \small "-t4 /2PS: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-t5 /2PS: câu 1, 12, 13 + Đ.2" }
        \line { \small "-t5 c /6TN: câu 1, 2, 3 + Đ.2" }
        \line { \small "-t7 l /11TN: câu 4, 5, 6 + Đ.1" }
        \line { \small "-t2 l /10TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t6 l /11TN: câu 1, 2, 3 + Đ.8" }
        \line { \small "-t4 l /13TN: câu 4, 5, 6 + Đ.2" }
        \line { \small "-Cn B /19TN: câu 1, 2, 3, 4 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Cn B /20TN: câu 1, 5, 6, 7 + Đ.1" }
        \line { \small "-Cn B /21TN: câu 1, 8, 9, 10, 11 + Đ.1" }
        \line { \small "-Cn C /30TN: câu 1, 12, 13 + Đ.2" }
        \line { \small "-t3 l /32TN: câu 1, 8, 9 + Đ.3" }
        \line { \small "-T.Tử Đạo: câu 1, 2, 3, 4 + Đ.6" }
        \line { \small "-T.Nam Nữ: câu 1, 2, 3, 4 + Đ.1 hoặc Đ.4" }
        \line { \small "-Rửa tội: câu 1, 3, 4, 7, 8, 9 + Đ.7" }
        \line { \small "-Hôn phối: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-tôn TV Trưởng: câu 1, 2, 5, 6 + Đ.9" }
        \line { \small "-Khấn dòng: câu 1, 2, 3, 4 + Đ.1 hoặc Đ.4" }
        \line { \small "-Mình Máu Chúa (NL): 1, 2, 3, 4 + Đ.1" }
        \line { \small "-T.Phêrô-Phaolô: câu 1, 2, 3, 4 + Đ.10" }
      }
    }
  %}
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.1" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMot
        }
      \new Lyrics \lyricsto beSop \loiPhanMot
    >>
  >>
  \layout {
    indent = 10
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
      instrumentName = \markup { \bold "Đ.2" }} <<
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
      instrumentName = \markup { \bold "Đ.3" }} <<
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
      instrumentName = \markup { \bold "Đ.4" }} <<
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
      instrumentName = \markup { \bold "Đ.5" }} <<
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
      instrumentName = \markup { \bold "Đ.6" }} <<
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
      instrumentName = \markup { \bold "Đ.7" }} <<
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

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.8" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanTam
        }
      \new Lyrics \lyricsto beSop \loiPhanTam
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
      instrumentName = \markup { \bold "Đ.9" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanChin
        }
      \new Lyrics \lyricsto beSop \loiPhanChin
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
      instrumentName = \markup { \bold "Đ.10" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMuoi
        }
      \new Lyrics \lyricsto beSop \loiPhanMuoi
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
    \new Staff <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMuoiMot
        }
      \new Lyrics \lyricsto beSop \loiPhanMuoiMot
    >>
  >>
  \layout {
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
