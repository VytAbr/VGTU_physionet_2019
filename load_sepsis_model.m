function model = load_sepsis_model()

    model{1} = load('models\Tree2');
    model{2} = load('models\Tree_med_All2');
    model{3} = load('models\Tree_long4');
%     model = [];
end
