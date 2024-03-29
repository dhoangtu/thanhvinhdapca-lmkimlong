% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 39"
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
  \partial 4 \tuplet 3/2 { g8 f g } |
  ef4. g8 |
  d4. bf16 d |
  ef4 r8 d |
  c4 \grace { g'16 (} \tuplet 3/2 { a8) fs g } |
  g4 \tuplet 3/2 { d'8 c d } |
  bf4. d16 g, |
  a4 \tuplet 3/2 { g8 a a } |
  fs4. fs16 d |
  g4 \tuplet 3/2 { g8 bf c } |
  d4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key bf \major
  \time 2/4
  \partial 8 d8 |
  g4 \tuplet 3/2 { bf,8 c c } |
  d4. d8 |
  <<
    {
      a'4. bf16 a |
      g4 \bar "|."
    }
    {
      c,4. d16 d |
      bf4
    }
  >>
}

nhacPhanBa = \relative c' {
  \key bf \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      bf'4. a16 a |
      a8 d d fs, |
      g2 ~ |
      g4 \bar "|."
    }
    {
      g4. g16 g |
      fs8 g d d |
      bf2 ~ |
      bf4
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key bf \major
  \time 2/4
  \partial 8 g16 g |
  f4 \tuplet 3/2 { a8 d d } |
  <<
    {
      bf4. d8 |
      f, a4 g8 |
      g4 \bar "|."
    }
    {
      g4. g8 |
      d c4 c8 |
      bf4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Tôi hằng trông đợi hết lòng ở nơi Chúa,
      nên Ngài cúi mình nghe tôi,
      Kéo tôi thoát khỏi hố diệt vong,
      qua những vũng lầy, kiên cường đi, nhịp chân trên đá.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Tôi hằng trông đợi hết lòng ở nơi Chúa,
      nên Ngài cúi mình nghe tôi,
      Khiến tôi mở miệng xướng bài ca,
      xin hát kính Ngài,
      Đây bài ca, một bài ca mới.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Tôi hằng trông đợi hết lòng ở nơi Chúa,
      nên Ngài cúi mình nghe tôi.
      Vững tin Chúa Trời, phúc lộc thay,
      Không dõi lối đường quân tàn hung và bọn kiêu hãnh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa đâu thích gì phẩm vật và hy lễ,
      nhưng Ngài đã mở tai tôi,
      Chúa đâu có đòi lễ toàn thiêu hay lễ xá tội,
      con liền thưa: Này con xin đến.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Sách ghi rõ ràng những lời về con đó:
      Con tìm ý Ngài vâng theo.
      Kính thân Chúa Trời, Chúa của con,
      bao huấn giới Ngài, đây lòng con hằng luôn ủ ấp.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Đức công chính Ngài, khấn nguyện truyền rao mãi
      trong ngày nhóm hội con dân.
      Kính xin Chúa Trời chứng nhận cho,
      vì Chúa biết rằng môi miệng con nào đâu im tiếng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Đức công chính Ngài, lưỡi này từng loan báo,
      không hề giữ để riêng con.
      Kính xin Chúa hằng dủ tình thương,
      Ơn phúc cứu độ, khi hội chung thực con không giấu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Kính xin Chúa Trời chớ đoạn tình âu yếm,
      mong Ngài mãi cảm thương con,
      Cúi xin Chúa hằng lấy tình thương
      đem đức tín thành bao bọc con, chở che con mãi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Ước chi những kẻ kiếm tìm thần nhan Chúa,
      trong Ngài hãy mừng vui lên.
      Ước chi những kẻ mến ảm ơn Thiên Chúa cứu độ,
      xưng tụng luôn: Ngài cao sang quá.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      Khiến con mở miệng tiến Ngài bài ca mới,
      ai nhìn sẽ cậy tin luôn.
      Đoái trông đến phận khốn cùng đây,
      Ơn Chúa cứu độ xin giải nguy, đừng khoan hoãn nữa.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, này con xin đến thực thi thánh ý Ngài.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, xin mau mau đến cứu độ con.
}

loiPhanBon = \lyricmode {
  Ta loan truyền Chúa đà chịu chết tới ngày Chúa quang lâm.
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
        \line { \small "-t4 c /1TN: câu 3, 4, 5, 6 + Đ.1" }
        \line { \small "-Cn A /2TN: câu 2, 4, 5, 6 + Đ.1" }
        \line { \small "-Cn B /2TN: câu 2, 4, 5, 6 + Đ.1" }
        \line { \small "-t5 l /2TN: câu 4, 5, 6, 9 + Đ.1" }
        \line { \small "-t3 l /3TN: câu 2, 4, 5, 6, 7 + Đ.1" }
        \line { \small "-Cn c /20TN: câu 1, 10 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t5 l /20TN: câu 3, 4, 5, 6 + Đ.1" }
        \line { \small "-t2 l /24TN: câu 4, 5, 6, 9 + Đ.3" }
        \line { \small "-t3 l /29TN: câu 4, 5, 6, 9 + Đ.1" }
        \line { \small "-lễ Truyền tin: câu 4, 5, 6 + Đ.1" }
        \line { \small "-Khấn dòng-Ơn gọi: câu 2, 3, 5, 6, 8 + Đ.1" }
        \line { \small "-Mình Máu Chúa (NL): câu 2, 3, 5, 6 + Đ.1" }
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
