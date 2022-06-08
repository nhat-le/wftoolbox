function dates_to_extract = get_session_dates(animal, delay, delaytype)
% Returns the list of dates with the corresponding delays
% animal: string, animal name
% delay: 0/0.5/1/2
% delaytype: 'half' or 'full'

switch animal
    case 'e57'
        if delay == 0 
            dates_to_extract = {'021721', '021821', '021921', '022321', '022621', '030221', '030321', '030421'};
        elseif delay == 0.5 && strcmp(delaytype, 'half')
            dates_to_extract = {'030521', '030621', '030821'};
        elseif delay == 1 && strcmp(delaytype, 'half')
            dates_to_extract = {'030921', '031021', '031221', '031621', '031721', '031921'};
        elseif delay == 2 && strcmp(delaytype, 'half')
            dates_to_extract = {'032221', '032321', '032521', '032621', '032921', '033021'};
        end


    case 'f01'
        if delay == 0 
            dates_to_extract = {'030421'};
        elseif delay == 0.5 && strcmp(delaytype, 'half')
            dates_to_extract = {'030521', '030621', '030821'};

        elseif delay == 1 && strcmp(delaytype, 'half')
            dates_to_extract = {'030921', '031121', '031221', '031521'};

        elseif delay == 2 && strcmp(delaytype, 'half')
            dates_to_extract = {'031621', '031721', '031921'};

        elseif delay == 0.5 && strcmp(delaytype, 'full')
            dates_to_extract = {'032321', '032521', '032621'};

        elseif delay == 1 && strcmp(delaytype, 'full')
            dates_to_extract = {'032921', '033021', '033121', '040121', '040221', '040521', ...
                '040621', '040721'};

        elseif delay == 2 && strcmp(delaytype, 'full')
            dates_to_extract = {'040921', '041421', '041621', '042021', '042121', '042321', '042721'};

        end


    case 'f02'
        if delay == 0
            dates_to_extract = {'022321', '022621', '030121', '030221', '030321', '030421'};

        elseif delay == 0.5 && strcmp(delaytype, 'half')
            dates_to_extract = {'030521', '030621', '030821'};

        elseif delay == 1 && strcmp(delaytype, 'half')
            dates_to_extract = {'030921', '031021', '031121'};

        elseif delay == 2 && strcmp(delaytype, 'half')
            dates_to_extract = {'031621', '031721', '031921', '032221', '032521', '032621'};

        elseif delay == 0.5 && strcmp(delaytype, 'full')
            dates_to_extract = {'033121', '040121', '040221', '040521', '040621'};

        elseif delay == 1 && strcmp(delaytype, 'full')
            dates_to_extract = {'040921', '041221', '041321', '041621', '041921'};

        elseif delay == 2 && strcmp(delaytype, 'full')
            dates_to_extract = {'042021', '042121', '042321', '042621', '042721'};
        end


    case 'f03'
        if delay == 0
            dates_to_extract = {'022621', '030121', '031921', '032221', '041921', '042021', '042121'};

        elseif delay == 0.3 && strcmp(delaytype, 'half')
            dates_to_extract = {'030321', '030821', '030921'};

        elseif delay == 0.5 && strcmp(delaytype, 'half')
            dates_to_extract = {'031021', '031121', '031221'};

        elseif delay == 1 && strcmp(delaytype, 'half')
            dates_to_extract = {'040121', '040221', '040621', '040721', '040921'};

        elseif delay == 0.5 && strcmp(delaytype, 'full')
            dates_to_extract = {'042121'};

        elseif delay == 1 && strcmp(delaytype, 'full')
            dates_to_extract= {'043021'};
        end

        
    case 'f04'
        if delay == 0
            dates_to_extract = {'030221', '030321', '031921'};

        elseif delay == 0.5 && strcmp(delaytype, 'half')
            dates_to_extract = {'031621', '032621', '032921'};

        elseif delay == 1 && strcmp(delaytype, 'half')
            dates_to_extract = {'040121', '040221', '040521', '040621'};

        elseif delay == 1 && strcmp(delaytype, 'full')
            dates_to_extract = {'040921', '041621', '041921', '042021'};

        elseif delay == 0.5 && strcmp(delaytype, 'full')
            dates_to_extract = {'043021'};
        end


    case 'f25'
        if delay == 1
            dates_to_extract = {'100121', '100421', '100521', '100621', '112321', ...
    '112421', '112521', '112621', '112921', '120321'};
        end
    case 'f30'
        return
    otherwise
        error('Invalid animal')


end


