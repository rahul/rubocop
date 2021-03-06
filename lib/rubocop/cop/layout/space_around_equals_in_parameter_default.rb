# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that the equals signs in parameter default assignments
      # have or don't have surrounding space depending on configuration.
      # @example
      #   # bad
      #   def some_method(arg1=:default, arg2=nil, arg3=[])
      #     # do something...
      #   end
      #
      #   # good
      #   def some_method(arg1 = :default, arg2 = nil, arg3 = [])
      #     # do something...
      #   end
      class SpaceAroundEqualsInParameterDefault < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = 'Surrounding space %<type>s in default value assignment.'.freeze

        def on_optarg(node)
          index = index_of_first_token(node)
          arg, equals, value = processed_source.tokens[index, 3]
          check_optarg(arg, equals, value)
        end

        private

        def check_optarg(arg, equals, value)
          space_on_both_sides = space_on_both_sides?(arg, equals, value)
          no_surrounding_space = no_surrounding_space?(arg, equals, value)

          if style == :space && space_on_both_sides ||
             style == :no_space && no_surrounding_space
            correct_style_detected
          else
            incorrect_style_detected(arg, value, space_on_both_sides,
                                     no_surrounding_space)
          end
        end

        def incorrect_style_detected(arg, value, space_on_both_sides,
                                     no_surrounding_space)
          range = range_between(arg.pos.end_pos, value.pos.begin_pos)
          add_offense(range, location: range) do
            if style == :space && no_surrounding_space ||
               style == :no_space && space_on_both_sides
              opposite_style_detected
            else
              unrecognized_style_detected
            end
          end
        end

        def space_on_both_sides?(arg, equals, value)
          space_between?(arg, equals) && space_between?(equals, value)
        end

        def no_surrounding_space?(arg, equals, value)
          !space_between?(arg, equals) && !space_between?(equals, value)
        end

        def message(_)
          format(MSG, type: style == :space ? 'missing' : 'detected')
        end

        def autocorrect(range)
          m = range.source.match(/=\s*(\S+)/)
          rest = m ? m.captures[0] : ''
          replacement = style == :space ? ' = ' : '='
          ->(corrector) { corrector.replace(range, replacement + rest) }
        end
      end
    end
  end
end
