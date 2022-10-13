% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 30"
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
      Con ẩn náu bên Ngài, đừng để con xấu hổ khi nào.
      Vì ân nghĩa Ngài, xin giải _ thoát con.
      Xin ghé tai về bên con, và mau mau cứu độ con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Con ẩn náu bên Ngài, đừng để con xấu hổ khi nào.
      Hồn con phó trọn trong bàn tay Chúa đây.
      Ôi Chúa trung hậu vô biên, Ngài yêu thương cứu chuộc con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Như rặng núi bao bọc, tựa thành con trú ẩn an toàn,
      Này con vẫn tìm nương nhờ Chúa liên.
      Ôi Chúa, xin vì Uy Danh mà thương luôn dắt dìu con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Con nẩn náu bên Ngài, đừng để sa lưới của quân thù.
      Hồn con phú trọn trong bàn tay Chúa đây.
      Ôi Chúa trung hậu vô biên, Ngài yêu thương cứu chuộc con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Muôn lạy Chúa con thờ, này hồn con phó ở tay Ngài.
      Ngài đã cứ chuộc bởi Ngài tín trung.
      Thân khốn nguy Ngài thương xem, lòng con khôn xiết mừng vui.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Muôn lạy Chúa con thờ, này hồn con phó ở tay Ngài.
      Ngài đã cứ chuộc bởi Ngài tín trung.
      Con vững tin Ngài khôn ngơi, lòng con khôn xiết mừng vui.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Xin nhìn đến con này, phận lầm than Chúa đã am tường,
      và không phó mặc cho bọn ác nhân.
      Trên lối đi rộng thênh thang dìu con đưa bước thảnh thơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Con bị lũ quân thù, bạn bè thân thích thày chê cười,
      vừa khi ngó mặt kinh tởm tránh xa,
      quên lãng như một thây mà, và coi như thứ bỏ đi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Bao kẻ đã buông lời độc địa cay đắng rủa thân này,
      nhìn quanh tứ bề bao điều khiếp kinh.
      Bao lũ toa rập bên con, và mưu toan lấy mạng con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Con hằng vững tin Ngài, Ngài là Thiên Chúa của con thờ,
      hồn con phó trọn trong bàn tay Chúa liên.
      Xin cứu con vượt qua tay địch quân đang bách hại con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Xin tỏa thánh nhan Ngài và dủ thương kẻ tôi đòi,
      chở che kỹ càng luôn ở Thánh Nhan.
      Cho thoát trăm ngàn mưu mô phàm nhân toan tính bày ra.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin tỏa thánh nhan Ngài và dủ thương cứu kẻ tôi đòi,
      nào ai vững lòng trông cậy Chúa liên.
      May hãy can trường thêm lên, và luôn luôn vững mạnh thêm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Ôi lòng Chúa nhân hậu, trọng đại thay,
      Chúa để cho người thành tâm vững lòng tôn sợ Chúa luôn.
      Thi thố ra cùng nhân gian, tặng ai bên Chúa ẩn thân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin ẩn giấu kỹ càn, đặt họ nương náu ở nhan Ngài,
      khỏi mưu ám hại bao kẻ ác tâm.
      Che chở trong lều cao sang, biệt xa bao tiếng thị phi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "15."
      Ca tụng Chúa nhân từ, đà rộng bạn phúc cả trong thành,
      dù khi khiếp sợ, con đã thốt lên:
      Ôi Chúa xua khỏi Tôn nhan, Ngày con kêu Chúa đà nghe.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "16."
      \override Lyrics.LyricText.font-shape = #'italic
      Mau hãy mến yêu Ngài, mọi kẻ trung hiếu ở trên đời.
      Ngài luôn giữ gìn bao kẻ tín trung.
      Nhưng với ai lòng kiêu căng, Ngài luôn truy oán thẳng tay.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, con xin phó linh hồn con trong tay Chúa.
}

loiPhanBa = \lyricmode {
  Hỡi những người tin cậy Chúa, mạnh bạo lên và hãy can trường lên.
}

loiPhanBon = \lyricmode {
  Lạy Chúa xin trở nên núi đá cho con ẩn náu.
}

loiPhanNam = \lyricmode {
  Lạy Chúa xin cứu độ con theo lượng từ bi Chúa.
}

loiPhanSau = \lyricmode {
  Lạy Cha, con xin phó linh hồn con ở trong tay Cha.
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
  %page-count = 2
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-ngày 26/12: câu 3, 4, 11 + Đ.1" }
        \line { \small "-t4 /2MC: câu 4, 9, 10 + Đ.4" }
        \line { \small "-t6 tuần Thánh: câu 2, 8, 10, 12 + Đ.5" }
        \line { \small "-lễ T.Tử đạo: câu 3, 6, 11 + Đ.1" }
        \line { \small "-xin ơn chết lành: câu 2, 7, 10, 12 + Đ.5" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 /3PS: câu 3, 6, 11 + Đ.1" }
        \line { \small "-t2 l /4TN: câu 13, 14, 15, 16 + Đ.2" }
        \line { \small "-Cn A /9TN: câu 1, 3, 12 + Đ.3" }
        \line { \small "-t4 c /11TN: câu 3, 6, 11 + Đ.1" }
        \line { \small "-lễ kính Thánh Giá: câu 2, 8, 10, 12 + Đ.5" }
        \line { \small "-lễ  Mẹ sầu bi: câu 1, 3, 4, 10, 13 + Đ.4" }
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
