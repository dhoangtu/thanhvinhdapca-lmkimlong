% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 79"
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
  \key f \major
  \time 2/4
  \partial 8 c16 c |
  d4 \tuplet 3/2 { f8 a g } |
  g4. g8 |
  a c d, f |
  g4 \tuplet 3/2 { e8 d d } |
  c4. e8 |
  g4. g16 f |
  f2 ~ |
  f4 r8 e |
  a4. f8 |
  bf4 \tuplet 3/2 { bf8 g bf } |
  c4 \tuplet 3/2 { a8 bf g } |
  a4 r8 g16 g |
  d4 \tuplet 3/2 { e8 f d } |
  c4. c16 e |
  g4 \tuplet 3/2 { g8 e g } |
  f4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 c4 |
  <<
    {
      a'4 a8 c |
      f,4. a8 |
      g2 |
      a8. g16 bf8 c |
      c4 c,8 g' |
      e4. g8
    }
    {
      f4 f8 e |
      d4. f8 |
      c2 |
      f8. e16 d8 e |
      e4 c8 b! |
      c4. c8
    }
  >>
  f2 ~ |
  f4 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 c4 |
  <<
    {
      a'4. a8 |
      f f4 bf8 |
      g2 ~ |
      g4 c8. bf16 |
      d8 d c bf |
      a4 f8 a |
      g8. g16 bf8 c
    }
    {
      f,4. f8 |
      d d4 g8 |
      e2 ~ |
      e4 a8. g16 |
      f8 f e e |
      f4 d8 f |
      e8. e16 d8 e
    }
  >>
  f4 \bar "|."
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 c4 |
  <<
    {
      a'4 f8 (a) |
      bf4. c8 |
      e, e g f |
      f4 \bar "|."
    }
    {
      f4 d8 (f) |
      g4. f8 |
      c c bf bf |
      a4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Lạy mục tử nhà Is -- ra -- el,
      Ngài chăn dắt nhà Giu -- se như chăn chiên cừu,
      xin hãy lắng tai nghe.
      Lạy Đấng ngự trên các thần hộ giá,
      xin hãy hiển linh,
      xin khơi dậy uy dũng của Ngài,
      mà mau đến cứu độ chúng con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Vạn lạy Ngài là Chúa thiên binh,
      còn cho đên tận khi nao vẫn nuôi cơn giận,
      không đáp tiếng con dân.
      Này bánh Ngài trao vẫn trộn nước mắt
      cho uống lệ rơi, bao quân thù chê diễu đêm ngày,
      thành nguyên cớ láng giềng đấu tranh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Này cụm nho Ngài bứng khi xưa,
      tận bên Ai -- cập xa xôi, đuổi bao dân tộc,
      dọn đất cấy nơi đây,
      và khiến cành lá vươn dài xa mãi cho tới đại dương,
      đâm thêm chồi ra tới sông Dài,
      và xanh tốt bóng rợp khắp nơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Vậy mà nay Ngài nỡ đang tâm dẹp phăng lũy rào vây quanh
      để cho bao người lui tới hái đem ăn,
      và để từng lũ heo rừng xông đến xô phá tràn lan,
      bao nhiêu là muông thú nương đống
      gặm ăn nát khác gì cỏ hoang.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Vạn lạy Ngài là Chúa thiên binh,
      Nguyện thương xót trở lại đi,
      Tít trên cung trời, xin ngó xuống trông xem,
      nguyện Chúa dủ thương thăm vườn nho cũ tay Chúa trồng xưa.
      Tay uy quyền xin hãy bảo vệ,
      chồi non đó hãy củng cố thêm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Rầy nguyện xin Ngài hãy ra tay
      chở che Đấng ngồi bên ngai,
      chính đây con người được Chúa xuống uy phong.
      Nguyện ước đoàn con không còn khi dám xa Chúa nữa đâu.
      Van xin Ngài cho sống an bình,
      Đoàn con mãi chúc tụng Thánh Danh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Rầy nguyện xin chẳng dám khi nao rời xa Chúa Trời nữa đâu.
      Cúi xin ơn Ngài cho sống vĩnh an luôn.
      Hợp tiếng đoàn con ca tụng danh Chúa,
      Thiên Chúa càn khôn.
      Con dân Ngài xin hãy quy hồi,
      Dọi Nhan Thánh cứu độ chúng con.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa xin đoái nhìn chúng con,
  xin tỏ nhan thánh Chúa và cứu độ chúng con.
}

loiPhanBa = \lyricmode {
  Lạy Chúa xin hồi phục chúng con.
  Xin tỏa ánh Tôn nhan rạng ngời
  để chúng con được ơn cứu độ.
}

loiPhanBon = \lyricmode {
  Vườn nho của Chúa chính là nhà Is -- ra -- el.
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
        \line { \small "-Cn B /1MV: câu 1, 5, 6 + Đ.1" }
        \line { \small "-t7 /2MV: câu 1, 5, 6 + Đ.2" }
        \line { \small "-Cn C /MV: câu 1, 5, 6 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 c /2TN: câu 1, 2 + Đ.1" }
        \line { \small "-t5 c /14TN: câu 1, 5 + Đ.1" }
        \line { \small "-Cn A /27TN: câu 3, 4, 5, 7 + Đ.3" }
        \line { \small "-mọi nhu cầu: câu 1, 2 + Đ.1" }
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
