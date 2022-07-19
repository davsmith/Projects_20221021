''' Builds a string to print at the beginning an example '''

"""
    In progress as of July 5, 2022

    Created: 7/5/2022

    Updates:

"""

class ExampleFormatter:
    def __init__(self, subpoint_label_type = 'lower'):
        self._indexes = [0,0]
        self._current_caption = ""
        self._subpoint_label_type = subpoint_label_type
        self._print_string = True

    def new_example(self, caption):
        self._current_caption = caption
        self._indexes[0] += 1
        self._indexes[1] = 0
        
        return self.build_heading_string()

    def end_example(self):
        return self.build_ending_string()

    def new_subpoint(self, caption):
        self._current_caption = caption
        self._indexes[1] += 1
        return(self.build_heading_string())

    def end_subpoint(self):
        return self.build_ending_string()

    def set_subpoint_index_type(self, index_type):
        ''' Indicates whether subpoints look like 1|a|A '''

        # Value should be 'digit', 'lower', or 'upper'        
        self._subpoint_label_type = index_type

    def build_heading_string(self):
        ''' Returns the full string to print before the example'''
        
        separator = ""
        index_labels = [str(self._indexes[0])]
        if self._indexes[1] > 0:
            if self._subpoint_label_type == 'lower':
                index_labels.append(chr(self._indexes[1]+ord('a')-1))
            elif self._subpoint_label_type == 'upper':
                index_labels.append(chr(self._indexes[1]+ord('A')-1))
            else:
                index_labels.append(str(self._indexes[1]))
                separator = '.'
        heading_string = f'----- Example {separator.join(index_labels)}: {self._current_caption} -----'
        if self._print_string:
            print(heading_string)

        return(heading_string)
                
    def build_ending_string(self):
        ending_string = "------------------------------\n"
        if self._print_string:
            print(ending_string)

def main():
    ex = ExampleFormatter('upper')
    ex.new_example("Functions")
    ex.new_subpoint("No arguments")
    ex.new_subpoint("Arguments with default values")
    ex.new_example("The Standard Library")
    ex.new_subpoint("The datetime module")
    ex.new_subpoint("The os module")
    ex.new_subpoint("The math module")
    ex.new_subpoint("The random module")
    ex.new_example("Loops and Iterations")
    ex.new_subpoint("for loops")
    ex.new_subpoint("while loops")
    ex.new_example("Error Handling")
    ex.new_example("Files")

if __name__ == '__main__':
    main()

