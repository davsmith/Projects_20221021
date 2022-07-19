''' (On Hold) Builds a string to print at the beginning and end of an example '''

"""
    Ascii codes for a-z are 97-122
    Ascii codes for A-Z are 65-90
    Ascii codes for 0-9 are 48-57
"""

class ExampleManager:
    ''' Class to manage the strings to label examples '''
    _ascii_indexes = {'lower':96, 'upper':64}

    def __init__(self, num_levels=2):
        ''' Initialize the number of levels in the example string '''
        self._num_levels = num_levels
        self.reset_counter()

    def reset_counter(self):
        ''' Reset all example counters to 1 '''
        self._level_indexes = [0] * self._num_levels


    def increment_counter(self, level):
        ''' Increment the specified counter, and reset all counters below the specified level '''
        self._level_indexes[level-1] += 1
        for i in range(level,len(self._level_indexes)):
            self._level_indexes[0] = 1

    def build_index_string(self, formats=('digit', 'upper')):
        ''' Create the digit/character representation of the level indexes '''

        # Build the list specifying how to format each level of the example string
        complete_formats = ['digit'] * max(len(self._level_indexes), len(formats))
        index_labels = []
        for index, format in enumerate(formats):
            complete_formats[index] = format

        # Build the list of formatted example levels (each level should be a digit or a letter)
        for i, example_index in enumerate(self._level_indexes):
            label_type = self._ascii_indexes.get(complete_formats[i], 'digit')

            if label_type == 'digit':
                label = str(self._level_indexes[i])
            else:
                label = chr(label_type + example_index)

            index_labels.append(label)

        # Return a concatenated string (e.g. 3.B.1 or 1.b)
        return(".".join(index_labels))
                



    def example_start(self, level=1, label=None):
        self.increment_counter(level)
        print(f'*** Example {self.build_index_string()}: {label} ***')

    def example_end(self):
        pass

example = ExampleManager(1)
# example.increment_counter(1)
# example.increment_counter(1)
# example.increment_counter(1)
print(f'Levels: {example._level_indexes}')
print(f'Index string: {example.build_index_string(["lower"])}')
